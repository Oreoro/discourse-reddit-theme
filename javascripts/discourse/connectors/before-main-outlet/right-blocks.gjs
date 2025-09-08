import Component from "@glimmer/component";
import { concat } from "@ember/helper";
import { action } from "@ember/object";
import { service } from "@ember/service";
import { htmlSafe } from "@ember/template";
import BlockBirthday from "../../components/blocks/birthday";
import BlockCta from "../../components/blocks/cta";
import BlockOnline from "../../components/blocks/online";
import BlockProfile from "../../components/blocks/profile";
import BlockTime from "../../components/blocks/time";
import BlockTopContributors from "../../components/blocks/top-contributors";
import BlockTopTopics from "../../components/blocks/top-topics";
import StickySidebar from "../../components/sticky-sidebar";

export default class RightBlocks extends Component {
  @service router;

  get blocks() {
    return settings.blocks;
  }

  get shouldRenderBlocks() {
    return (
      this.router.currentRoute.parent?.name === "discovery" &&
      this.router.currentRouteName !== "discovery.categories"
    );
  }

  @action
  blockify(block) {
    switch (block.name) {
      case "cta":
        return BlockCta;
      case "top_contributors":
        return BlockTopContributors;
      case "top_topics":
        return BlockTopTopics;
      case "time":
        return BlockTime;
      case "profile":
        return BlockProfile;
      case "online":
        return BlockOnline;
      case "birthday":
        return BlockBirthday;
    }
  }

  <template>
    {{#if this.shouldRenderBlocks}}
      <div class="blocks --right">
        <div class="blocks__wrapper">
          <!-- Enhanced Reddit-style sidebar -->
          <div class="reddit-community-info">
            <div class="reddit-community-header">
              📋 About Community
            </div>
            <div class="reddit-community-content">
              <div class="reddit-community-stats">
                <div class="reddit-stat">
                  <span class="reddit-stat-number">1.2k</span>
                  <span class="reddit-stat-label">👥 Members</span>
                </div>
                <div class="reddit-stat">
                  <span class="reddit-stat-number">62</span>
                  <span class="reddit-stat-label">🟢 Online</span>
                </div>
                <div class="reddit-stat">
                  <span class="reddit-stat-number">#15</span>
                  <span class="reddit-stat-label">📈 Ranked</span>
                </div>
              </div>
              
              <div class="reddit-community-description">
                Welcome to our community! Share your thoughts, ask questions, and connect with fellow members.
              </div>

              <div class="reddit-community-rules">
                <div class="reddit-rules-header">📜 Community Rules</div>
                <div class="reddit-rule">
                  <span class="reddit-rule-number">1.</span>
                  <span class="reddit-rule-text">Be respectful and civil</span>
                </div>
                <div class="reddit-rule">
                  <span class="reddit-rule-number">2.</span>
                  <span class="reddit-rule-text">No spam or self-promotion</span>
                </div>
                <div class="reddit-rule">
                  <span class="reddit-rule-number">3.</span>
                  <span class="reddit-rule-text">Stay on topic</span>
                </div>
              </div>

              <button type="button" class="reddit-join-button">
                ✅ Joined
              </button>
            </div>
          </div>
          
          <!-- Trending Communities -->
          <div class="reddit-trending">
            <div class="reddit-trending-header">
              🔥 Trending Communities
            </div>
            <div class="reddit-trending-list">
              <div class="reddit-trending-item">
                <div class="reddit-trending-rank">1</div>
                <div class="reddit-trending-info">
                  <a href="/c/general" class="reddit-trending-name">r/general</a>
                  <div class="reddit-trending-members">850 members</div>
                </div>
              </div>
              <div class="reddit-trending-item">
                <div class="reddit-trending-rank">2</div>
                <div class="reddit-trending-info">
                  <a href="/c/help" class="reddit-trending-name">r/help</a>
                  <div class="reddit-trending-members">623 members</div>
                </div>
              </div>
              <div class="reddit-trending-item">
                <div class="reddit-trending-rank">3</div>
                <div class="reddit-trending-info">
                  <a href="/c/announcements" class="reddit-trending-name">r/announcements</a>
                  <div class="reddit-trending-members">412 members</div>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>
    {{/if}}
  </template>
}
