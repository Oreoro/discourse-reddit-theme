import Component from "@glimmer/component";
import { tracked } from "@glimmer/tracking";
import { action } from "@ember/object";
import { on } from "@ember/modifier";
import { fn } from "@ember/helper";
import { eq } from "truth-helpers";
import { if as ifHelper } from "@ember/helper";

export default class RedditSortBar extends Component {
  @tracked activeSort = "hot";

  sortOptions = [
    { key: "hot", label: "🔥 Hot", icon: "fire", description: "Posts trending now" },
    { key: "new", label: "✨ New", icon: "clock", description: "Latest posts" },
    { key: "top", label: "🚀 Top", icon: "arrow-up", description: "Highest rated" },
    { key: "rising", label: "📈 Rising", icon: "trending-up", description: "Growing fast" }
  ];

  @action
  changeSort(sortKey) {
    this.activeSort = sortKey;
    this.args.onSortChange?.(sortKey);
    
    // Actually navigate to the sorted view
    const currentPath = window.location.pathname;
    let newPath;
    
    switch (sortKey) {
      case "new":
        newPath = currentPath.includes("/c/") ? currentPath + "/l/latest" : "/latest";
        break;
      case "top":
        newPath = currentPath.includes("/c/") ? currentPath + "/l/top" : "/top";
        break;
      case "hot":
      default:
        newPath = currentPath.replace(/\/l\/(latest|top|new)$/, "");
        break;
    }
    
    if (newPath !== window.location.pathname) {
      window.location.href = newPath;
    }
  }

  <template>
    <div class="reddit-sort-bar">
      <div class="reddit-sort-options">
        {{#each this.sortOptions as |option|}}
          <div
            class="reddit-sort-option {{ifHelper (eq this.activeSort option.key) 'active'}}"
            {{on "click" (fn this.changeSort option.key)}}
            title={{option.description}}
          >
            <span class="reddit-sort-label">{{option.label}}</span>
            {{#ifHelper (eq this.activeSort option.key)}}
              <span class="reddit-sort-indicator">•</span>
            {{/ifHelper}}
          </div>
        {{/each}}
      </div>
      <div class="reddit-view-toggle">
        <button class="reddit-view-option active" title="Card view">
          📋 Posts
        </button>
        <button class="reddit-view-option" title="Compact view">
          📝 Compact
        </button>
      </div>
    </div>
  </template>
}
