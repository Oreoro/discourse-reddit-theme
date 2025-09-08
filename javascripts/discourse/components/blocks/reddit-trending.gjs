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
      // Get categories and sort by topic count
      const categories = this.store.findAll("category");
      this.trendingCategories = categories
        .filter(cat => !cat.parent_category_id && cat.topic_count > 0)
        .sort((a, b) => b.topic_count - a.topic_count)
        .slice(0, 5)
        .map((cat, index) => ({
          rank: index + 1,
          name: cat.name,
          slug: cat.slug,
          memberCount: cat.topic_count * 10, // Estimate
          url: cat.url
        }));
    } catch (error) {
      console.error("Failed to load trending categories:", error);
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
