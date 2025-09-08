import Component from "@glimmer/component";
import { tracked } from "@glimmer/tracking";
import { action } from "@ember/object";
import { service } from "@ember/service";
import { ajax } from "discourse/lib/ajax";
import { popupAjaxError } from "discourse/lib/ajax-error";
import DButton from "discourse/components/d-button";
import icon from "discourse-common/helpers/d-icon";
import { eq } from "truth-helpers";
import { if as ifHelper } from "@ember/helper";

export default class RedditVoteWidget extends Component {
  @service currentUser;
  @service router;
  @tracked voteState = "none"; // "up", "down", or "none"
  @tracked score = 0;
  @tracked isLoading = false;

  constructor(owner, args) {
    super(owner, args);
    this.initializeFromTopic();
  }

  initializeFromTopic() {
    const topic = this.args.topic;
    if (!topic) return;

    // Use Discourse's like count as the base score
    this.score = topic.like_count || 0;
    
    // Check if current user has liked this topic
    if (this.currentUser && topic.liked) {
      this.voteState = "up";
    } else {
      this.voteState = "none";
    }
  }

  @action
  async upvote() {
    if (!this.currentUser) {
      this.router.transitionTo("login");
      return;
    }

    if (this.isLoading) return;

    const topic = this.args.topic;
    if (!topic) return;

    this.isLoading = true;

    try {
      if (this.voteState === "up") {
        // Remove upvote (unlike)
        await this.unlikeTopic(topic);
        this.voteState = "none";
        this.score = Math.max(0, this.score - 1);
      } else {
        // Add upvote (like)
        await this.likeTopic(topic);
        const prevState = this.voteState;
        this.voteState = "up";
        // Adjust score based on previous state
        this.score += prevState === "down" ? 2 : 1;
      }
    } catch (error) {
      popupAjaxError(error);
      // Revert on error
      this.initializeFromTopic();
    } finally {
      this.isLoading = false;
    }
  }

  @action
  async downvote() {
    if (!this.currentUser) {
      this.router.transitionTo("login");
      return;
    }

    if (this.isLoading) return;

    // Note: Discourse doesn't have native downvoting, so we'll simulate it
    // In a real implementation, you'd need a plugin for downvotes
    const prevState = this.voteState;
    
    if (this.voteState === "down") {
      // Remove downvote
      this.voteState = "none";
      this.score += 1;
    } else {
      // Add downvote
      if (this.voteState === "up") {
        // Remove existing upvote first
        try {
          await this.unlikeTopic(this.args.topic);
        } catch (error) {
          popupAjaxError(error);
          return;
        }
      }
      
      this.voteState = "down";
      this.score -= prevState === "up" ? 2 : 1;
      this.score = Math.max(0, this.score); // Prevent negative scores
    }
  }

  async likeTopic(topic) {
    // Use the correct endpoint for topic liking
    const result = await ajax(`/t/${topic.id}/toggle-like`, {
      type: "PUT"
    });
    
    // Update topic object
    topic.setProperties({
      liked: true,
      like_count: (topic.like_count || 0) + 1
    });

    return result;
  }

  async unlikeTopic(topic) {
    // Use the correct endpoint for topic liking
    const result = await ajax(`/t/${topic.id}/toggle-like`, {
      type: "PUT"
    });
    
    // Update topic object
    topic.setProperties({
      liked: false,
      like_count: Math.max(0, (topic.like_count || 0) - 1)
    });

    return result;
  }

  get upvoteClass() {
    return `reddit-vote-arrow reddit-upvote ${
      this.voteState === "up" ? "voted" : ""
    }`;
  }

  get downvoteClass() {
    return `reddit-vote-arrow reddit-downvote ${
      this.voteState === "down" ? "voted" : ""
    }`;
  }

  get formattedScore() {
    const score = Math.abs(this.score);
    if (score >= 1000000) {
      return (score / 1000000).toFixed(1) + "M";
    }
    if (score >= 1000) {
      return (score / 1000).toFixed(1) + "k";
    }
    return score.toString();
  }

  get scoreClass() {
    if (this.score > 0) return "positive";
    if (this.score < 0) return "negative";
    return "";
  }

  get ariaLabel() {
    const score = this.formattedScore;
    const state = this.voteState === "up" ? " (upvoted)" : 
                  this.voteState === "down" ? " (downvoted)" : "";
    return `${score} points${state}`;
  }

  <template>
    <div class="reddit-vote-widget" role="group" aria-label="Vote on this post">
      <DButton
        @action={{this.upvote}}
        @disabled={{this.isLoading}}
        @translatedTitle={{ifHelper this.voteState "Remove upvote" "Upvote"}}
        class={{this.upvoteClass}}
        @icon={{ifHelper this.isLoading "spinner" "chevron-up"}}
        aria-label={{ifHelper (eq this.voteState "up") "Remove upvote" "Upvote this post"}}
        aria-pressed={{eq this.voteState "up"}}
      />
      <div 
        class="reddit-vote-score {{this.scoreClass}}"
        aria-label={{this.ariaLabel}}
        role="status"
        aria-live="polite"
      >
        {{this.formattedScore}}
      </div>
      <DButton
        @action={{this.downvote}}
        @disabled={{this.isLoading}}
        @translatedTitle={{ifHelper (eq this.voteState "down") "Remove downvote" "Downvote"}}
        class={{this.downvoteClass}}
        @icon="chevron-down"
        aria-label={{ifHelper (eq this.voteState "down") "Remove downvote" "Downvote this post"}}
        aria-pressed={{eq this.voteState "down"}}
      />
    </div>
  </template>
}
