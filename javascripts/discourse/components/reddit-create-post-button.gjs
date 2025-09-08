import Component from "@glimmer/component";
import { action } from "@ember/object";
import { service } from "@ember/service";
import DButton from "discourse/components/d-button";
import icon from "discourse/helpers/d-icon";

export default class RedditCreatePostButton extends Component {
  @service currentUser;
  @service router;

  @action
  createPost() {
    if (!this.currentUser) {
      this.router.transitionTo("login");
      return;
    }
    this.router.transitionTo("new-topic");
  }

  <template>
    <div class="reddit-create-post-container">
      <DButton
        @action={{this.createPost}}
        @icon="plus"
        @label="Create Post"
        class="reddit-create-post-btn"
      />
    </div>
  </template>
}
