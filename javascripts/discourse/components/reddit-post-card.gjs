import Component from "@glimmer/component";
import { action } from "@ember/object";
import { service } from "@ember/service";
import { tracked } from "@glimmer/tracking";
import { on } from "@ember/modifier";
import RedditVoteWidget from "./reddit-vote-widget";
import formatDate from "discourse/helpers/format-date";
import UserLink from "discourse/components/user-link";
import icon from "discourse/helpers/d-icon";
import { if as ifHelper } from "@ember/helper";

export default class RedditPostCard extends Component {
  @service siteSettings;
  @service router;
  @tracked imageError = false;

  get topic() {
    return this.args.topic;
  }

  get hasImage() {
    return !this.imageError && 
           this.topic?.thumbnails && 
           this.topic.thumbnails.length > 0;
  }

  get thumbnailUrl() {
    if (this.hasImage) {
      return this.topic.thumbnails[0].url;
    }
    return null;
  }

  get excerpt() {
    // Safely get excerpt with fallbacks
    return this.topic?.excerpt || 
           this.topic?.fancy_title || 
           this.topic?.title || 
           "No content available";
  }

  get timeAgo() {
    if (!this.topic?.created_at) return "unknown";
    
    const createdAt = new Date(this.topic.created_at);
    const now = Date.now();
    const diffMs = now - createdAt.getTime();
    
    if (diffMs < 0) return "now"; // Future date fallback
    
    const minutes = Math.floor(diffMs / (1000 * 60));
    const hours = Math.floor(diffMs / (1000 * 60 * 60));
    const days = Math.floor(diffMs / (1000 * 60 * 60 * 24));
    const months = Math.floor(days / 30);
    const years = Math.floor(days / 365);
    
    if (minutes < 1) return "now";
    if (minutes < 60) return `${minutes}m`;
    if (hours < 24) return `${hours}h`;
    if (days < 30) return `${days}d`;
    if (months < 12) return `${months}mo`;
    return `${years}y`;
  }

  get replyCount() {
    const count = (this.topic?.posts_count || 1) - 1;
    return Math.max(0, count);
  }

  get categoryName() {
    return this.topic?.category?.name || "uncategorized";
  }

  get categoryUrl() {
    return this.topic?.category?.url || "/c/uncategorized";
  }

  get authorInfo() {
    const posters = this.topic?.posters;
    if (!posters || posters.length === 0) {
      return { username: "unknown", user: null };
    }
    
    const firstPoster = posters[0];
    return {
      username: firstPoster.user?.username || "deleted",
      user: firstPoster.user
    };
  }

  get postUrl() {
    return this.topic?.url || "#";
  }

  get isLocked() {
    return this.topic?.closed || this.topic?.archived;
  }

  get isPinned() {
    return this.topic?.pinned || this.topic?.pinned_globally;
  }

  @action
  handleImageError() {
    this.imageError = true;
  }

  @action
  handlePostClick(event) {
    // Allow normal link behavior but add analytics if needed
    if (this.args.onPostClick) {
      this.args.onPostClick(this.topic);
    }
  }

  @action
  handleLike() {
    // Trigger Discourse's like action
    this.args.onLike?.(this.topic);
  }

  @action
  handleDownvote() {
    // Custom downvote handling (would need backend support)
    this.args.onDownvote?.(this.topic);
  }

  <template>
    <article class="reddit-post-card {{ifHelper this.isPinned 'pinned'}} {{ifHelper this.isLocked 'locked'}}" 
             role="article" 
             aria-label="Post: {{this.topic.title}}">
      <div class="reddit-post-content">
        <RedditVoteWidget
          @topic={{this.topic}}
          @onLike={{this.handleLike}}
          @onDownvote={{this.handleDownvote}}
        />
        
        <div class="reddit-post-main">
          <header class="reddit-post-header">
            <a href={{this.categoryUrl}} class="reddit-community" aria-label="Category: {{this.categoryName}}">
              r/{{this.categoryName}}
            </a>
            <span class="reddit-separator" aria-hidden="true">•</span>
            <span class="reddit-posted-by">Posted by</span>
            {{#ifHelper this.authorInfo.user}}
              <UserLink @user={{this.authorInfo.user}} @hideAvatar={{true}} class="reddit-author" />
            {{else}}
              <span class="reddit-author deleted-user">{{this.authorInfo.username}}</span>
            {{/ifHelper}}
            <span class="reddit-separator" aria-hidden="true">•</span>
            <time class="reddit-timestamp" datetime={{this.topic.created_at}} title={{formatDate this.topic.created_at}}>
              {{this.timeAgo}}
            </time>
            {{#ifHelper this.isPinned}}
              <span class="reddit-pinned" title="Pinned post">
                {{icon "thumbtack"}}
              </span>
            {{/ifHelper}}
            {{#ifHelper this.isLocked}}
              <span class="reddit-locked" title="Locked post">
                {{icon "lock"}}
              </span>
            {{/ifHelper}}
          </header>

          <h3 class="reddit-post-title">
            <a href={{this.postUrl}} {{on "click" this.handlePostClick}}>
              {{this.topic.title}}
            </a>
          </h3>

          {{#ifHelper this.excerpt}}
            <div class="reddit-post-excerpt" role="complementary" aria-label="Post excerpt">
              {{this.excerpt}}
            </div>
          {{/ifHelper}}

          <footer class="reddit-post-footer">
            <a href={{this.postUrl}} class="reddit-action-button comments" aria-label="{{this.replyCount}} comments">
              {{icon "comment"}}
              <span>{{this.replyCount}} comments</span>
            </a>
            <button type="button" class="reddit-action-button share" aria-label="Share this post">
              {{icon "share"}}
              <span>Share</span>
            </button>
            <button type="button" class="reddit-action-button save" aria-label="Save this post">
              {{icon "bookmark"}}
              <span>Save</span>
            </button>
            {{#ifHelper this.isLocked}}
              <span class="reddit-action-button locked" aria-label="Post is locked">
                {{icon "lock"}}
                <span>Locked</span>
              </span>
            {{/ifHelper}}
          </footer>
        </div>

        {{#ifHelper this.hasImage}}
          <div class="reddit-post-thumbnail" role="img" aria-label="Post image">
            <img 
              src={{this.thumbnailUrl}} 
              alt="Thumbnail for {{this.topic.title}}" 
              loading="lazy"
              {{on "error" this.handleImageError}}
            >
          </div>
        {{else}}
          <div class="reddit-post-thumbnail reddit-thumbnail-placeholder" role="img" aria-label="No image available">
            {{icon "image"}}
          </div>
        {{/ifHelper}}
      </div>
    </article>
  </template>
}
