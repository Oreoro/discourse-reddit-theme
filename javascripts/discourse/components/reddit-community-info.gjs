import Component from "@glimmer/component";
import { service } from "@ember/service";
import DButton from "discourse/components/d-button";
import { if as ifHelper } from "@ember/helper";

export default class RedditCommunityInfo extends Component {
  @service site;
  @service currentUser;

  get memberCount() {
    return this.site.user_count || 0;
  }

  get onlineCount() {
    // This would need real implementation
    return Math.floor(this.memberCount * 0.05);
  }

  get formattedMemberCount() {
    const count = this.memberCount;
    if (count >= 1000000) {
      return (count / 1000000).toFixed(1) + "M";
    }
    if (count >= 1000) {
      return (count / 1000).toFixed(1) + "k";
    }
    return count.toString();
  }

  get formattedOnlineCount() {
    const count = this.onlineCount;
    if (count >= 1000) {
      return (count / 1000).toFixed(1) + "k";
    }
    return count.toString();
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
