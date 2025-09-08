import Component from "@glimmer/component";
import { service } from "@ember/service";
import DButton from "discourse/components/d-button";
import { if as ifHelper } from "@ember/helper";

export default class RedditCommunityInfo extends Component {
  @service site;
  @service currentUser;

  get memberCount() {
    try {
      return this.site?.user_count || 1234;
    } catch (error) {
      return 1234; // Static fallback to prevent errors
    }
  }

  get onlineCount() {
    try {
      return Math.floor(this.memberCount * 0.05) || 62;
    } catch (error) {
      return 62; // Static fallback
    }
  }

  get formattedMemberCount() {
    try {
      const count = this.memberCount;
      if (count >= 1000000) {
        return (count / 1000000).toFixed(1) + "M";
      }
      if (count >= 1000) {
        return (count / 1000).toFixed(1) + "k";
      }
      return count.toString();
    } catch (error) {
      return "1.2k"; // Static fallback
    }
  }

  get formattedOnlineCount() {
    try {
      const count = this.onlineCount;
      if (count >= 1000) {
        return (count / 1000).toFixed(1) + "k";
      }
      return count.toString();
    } catch (error) {
      return "62"; // Static fallback
    }
  }

  <template>
    <div class="reddit-community-info">
      <div class="reddit-community-header">
        About Community
      </div>
      <div class="reddit-community-content">
        <div class="reddit-community-stats">
          <div class="reddit-stat">
            <span class="reddit-stat-number">{{this.formattedMemberCount}}</span>
            <span class="reddit-stat-label">Members</span>
          </div>
          <div class="reddit-stat">
            <span class="reddit-stat-number">{{this.formattedOnlineCount}}</span>
            <span class="reddit-stat-label">Online</span>
          </div>
        </div>
        
        <div class="reddit-community-description">
          {{#ifHelper @description}}
            {{@description}}
          {{else}}
            Welcome to our community! Join the discussion and share your thoughts with fellow members.
          {{/ifHelper}}
        </div>

        {{#ifHelper this.currentUser}}
          <DButton
            @action={{@onJoin}}
            @label="Joined"
            class="reddit-join-button joined"
          />
        {{else}}
          <DButton
            @action={{@onJoin}}
            @label="Join"
            class="reddit-join-button"
          />
        {{/ifHelper}}
      </div>
    </div>
  </template>
}
