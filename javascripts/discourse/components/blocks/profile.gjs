import Component from "@glimmer/component";

export default class Profile extends Component {
  <template>
    <div class="reddit-community-info">
      <div class="reddit-community-header">
        About Community
      </div>
      <div class="reddit-community-content">
        <div class="reddit-community-stats">
          <div class="reddit-stat">
            <span class="reddit-stat-number">1.2k</span>
            <span class="reddit-stat-label">Members</span>
          </div>
          <div class="reddit-stat">
            <span class="reddit-stat-number">62</span>
            <span class="reddit-stat-label">Online</span>
          </div>
        </div>
        
        <div class="reddit-community-description">
          Welcome to our community! Share your thoughts and connect with fellow members.
        </div>

        <button type="button" class="reddit-join-button">
          Join Community
        </button>
      </div>
    </div>
  </template>
}
