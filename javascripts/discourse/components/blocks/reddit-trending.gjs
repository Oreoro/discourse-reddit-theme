import Component from "@glimmer/component";
import { tracked } from "@glimmer/tracking";
import { service } from "@ember/service";

export default class RedditTrending extends Component {
  @service store;
  @tracked trendingCategories = [];

  constructor(owner, args) {
    super(owner, args);
    this.loadTrendingCategories();
  }

  async loadTrendingCategories() {
    try {
      // Simplified - just show static trending communities to prevent infinite loops
      this.trendingCategories = [
        { rank: 1, name: "General", slug: "general", memberCount: 1200, url: "/c/general" },
        { rank: 2, name: "Help", slug: "help", memberCount: 850, url: "/c/help" },
        { rank: 3, name: "Announcements", slug: "announcements", memberCount: 600, url: "/c/announcements" },
        { rank: 4, name: "Feedback", slug: "feedback", memberCount: 400, url: "/c/feedback" },
        { rank: 5, name: "Meta", slug: "meta", memberCount: 200, url: "/c/meta" }
      ];
    } catch (error) {
      console.error("Failed to load trending categories:", error);
      this.trendingCategories = [];
    }
  }

  formatMemberCount(count) {
    if (count >= 1000000) {
      return (count / 1000000).toFixed(1) + "M";
    }
    if (count >= 1000) {
      return (count / 1000).toFixed(1) + "k";
    }
    return count.toString();
  }

  <template>
    <div class="reddit-trending">
      <div class="reddit-trending-header">
        Trending Communities
      </div>
      <div class="reddit-trending-list">
        {{#each this.trendingCategories as |category|}}
          <div class="reddit-trending-item">
            <div class="reddit-trending-rank">{{category.rank}}</div>
            <div class="reddit-trending-info">
              <a href={{category.url}} class="reddit-trending-name">
                r/{{category.name}}
              </a>
              <div class="reddit-trending-members">
                {{this.formatMemberCount category.memberCount}} members
              </div>
            </div>
          </div>
        {{/each}}
      </div>
    </div>
  </template>
}
