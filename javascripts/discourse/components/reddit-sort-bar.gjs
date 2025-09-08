import Component from "@glimmer/component";
import { tracked } from "@glimmer/tracking";
import { action } from "@ember/object";

export default class RedditSortBar extends Component {
  @tracked activeSort = "hot";

  sortOptions = [
    { key: "hot", label: "Hot", icon: "fire" },
    { key: "new", label: "New", icon: "clock" },
    { key: "top", label: "Top", icon: "arrow-up" },
    { key: "rising", label: "Rising", icon: "trending-up" }
  ];

  @action
  changeSort(sortKey) {
    this.activeSort = sortKey;
    this.args.onSortChange?.(sortKey);
  }

  <template>
    <div class="reddit-sort-bar">
      <div class="reddit-sort-options">
        {{#each this.sortOptions as |option|}}
          <div
            class="reddit-sort-option {{if (eq this.activeSort option.key) 'active'}}"
            {{on "click" (fn this.changeSort option.key)}}
          >
            {{option.label}}
          </div>
        {{/each}}
      </div>
    </div>
  </template>
}
