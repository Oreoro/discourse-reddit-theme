import Component from "@glimmer/component";
import RedditCommunityInfo from "../reddit-community-info";
import { fn } from "@ember/helper";
import { noop } from "@ember/utils";

export default class Profile extends Component {
  <template>
    <RedditCommunityInfo 
      @description="Welcome to our community! Share your thoughts and connect with fellow members."
      @onJoin={{fn noop}}
    />
  </template>
}
