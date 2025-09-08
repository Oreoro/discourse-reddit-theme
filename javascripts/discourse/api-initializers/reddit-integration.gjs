import { apiInitializer } from "discourse/lib/api";
import { schedule } from "@ember/runloop";

export default apiInitializer("1.8.0", (api) => {
  // Add Reddit-style classes to topic lists
  api.modifyClass("component:topic-list", {
    classNames: ["reddit-feed"]
  });

  // Add custom CSS classes for Reddit styling
  api.addTopicListCellClassNames(["reddit-post-cell"]);

  // Enhanced page change handler with better error handling
  api.onPageChange((url, title) => {
    if (shouldApplyRedditStyling(url)) {
      schedule("afterRender", () => {
        applyRedditStyling();
        addRedditSortBar();
      });
    }
  });

  // Add Reddit-style header elements
  api.decorateWidget("header-buttons:before", (decorator) => {
    if (decorator.currentUser) {
      return decorator.h("a.reddit-create-post-header", {
        href: "/new-topic",
        title: "Create Post",
        attributes: { "aria-label": "Create new post" }
      }, [
        decorator.h("i.d-icon.d-icon-plus"),
        "Post"
      ]);
    }
  });

  // Add topic status indicators
  api.includePostAttributes("reddit_score", "reddit_vote_state");

  // Custom topic list item renderer
  api.modifyClass("component:topic-list-item", {
    classNames: ["reddit-post-card"],
    classNameBindings: [
      "topic.pinned:pinned",
      "topic.closed:locked",
      "topic.archived:archived"
    ],

    actions: {
      toggleLike() {
        const topic = this.topic;
        if (!this.currentUser) {
          return this.router.transitionTo("login");
        }
        
        return topic.toggleLike();
      }
    }
  });

  function shouldApplyRedditStyling(url) {
    const redditPages = ["/", "/latest", "/new", "/top", "/hot"];
    const isRedditPage = redditPages.some(page => url === page || url.startsWith(page));
    const isCategoryPage = url.includes("/c/");
    const isTagPage = url.includes("/tag/");
    
    return isRedditPage || isCategoryPage || isTagPage;
  }

  function applyRedditStyling() {
    try {
      const topicListItems = document.querySelectorAll(".topic-list-item:not(.reddit-styled)");
      
      topicListItems.forEach((item, index) => {
        item.classList.add("reddit-styled");
        
        // Add entrance animation with stagger
        item.style.animationDelay = `${index * 0.05}s`;
        item.classList.add("slide-in-up");
        
        // Remove animation class after animation completes
        setTimeout(() => {
          item.classList.remove("slide-in-up");
          item.style.animationDelay = "";
        }, 600 + (index * 50));
      });
    } catch (error) {
      console.warn("Reddit styling application failed:", error);
    }
  }

  function addRedditSortBar() {
    try {
      const topicList = document.querySelector(".topic-list-container");
      if (!topicList || topicList.querySelector(".reddit-sort-bar")) return;

      const sortBar = createSortBar();
      topicList.insertBefore(sortBar, topicList.firstChild);
    } catch (error) {
      console.warn("Sort bar creation failed:", error);
    }
  }

  function createSortBar() {
    const sortBar = document.createElement("div");
    sortBar.className = "reddit-sort-bar";
    sortBar.setAttribute("role", "navigation");
    sortBar.setAttribute("aria-label", "Post sorting options");
    
    const currentSort = getCurrentSort();
    
    sortBar.innerHTML = `
      <div class="reddit-sort-options">
        ${createSortOption("hot", "🔥 Hot", currentSort === "hot")}
        ${createSortOption("latest", "✨ New", currentSort === "latest")}
        ${createSortOption("top", "🚀 Top", currentSort === "top")}
        ${createSortOption("new", "📈 Rising", currentSort === "new")}
      </div>
      <div class="reddit-view-toggle">
        <button class="toggle-option active" title="Card view" aria-label="Card view">
          <i class="d-icon d-icon-th-large"></i>
        </button>
        <button class="toggle-option" title="Compact view" aria-label="Compact view">
          <i class="d-icon d-icon-list"></i>
        </button>
      </div>
    `;
    
    // Add event listeners
    addSortEventListeners(sortBar);
    addViewToggleListeners(sortBar);
    
    return sortBar;
  }

  function createSortOption(sort, label, isActive) {
    return `
      <button 
        class="reddit-sort-option ${isActive ? 'active' : ''}" 
        data-sort="${sort}"
        aria-pressed="${isActive}"
        aria-label="Sort by ${label}"
      >
        ${label}
      </button>
    `;
  }

  function getCurrentSort() {
    const path = window.location.pathname;
    const params = new URLSearchParams(window.location.search);
    
    if (path.includes("/top")) return "top";
    if (path.includes("/new")) return "new";
    if (params.get("order") === "latest") return "latest";
    
    return "hot"; // default
  }

  function addSortEventListeners(sortBar) {
    sortBar.querySelectorAll(".reddit-sort-option").forEach(option => {
      option.addEventListener("click", (e) => {
        e.preventDefault();
        
        const sortType = e.currentTarget.dataset.sort;
        const currentPath = window.location.pathname;
        
        // Update active state
        sortBar.querySelectorAll(".reddit-sort-option").forEach(opt => {
          opt.classList.remove("active");
          opt.setAttribute("aria-pressed", "false");
        });
        
        e.currentTarget.classList.add("active");
        e.currentTarget.setAttribute("aria-pressed", "true");
        
        // Navigate to sorted view
        let newPath;
        switch (sortType) {
          case "latest":
            newPath = currentPath.includes("/c/") ? currentPath + "/l/latest" : "/latest";
            break;
          case "top":
            newPath = currentPath.includes("/c/") ? currentPath + "/l/top" : "/top";
            break;
          case "new":
            newPath = currentPath.includes("/c/") ? currentPath + "/l/new" : "/new";
            break;
          default:
            newPath = currentPath.replace(/\/l\/(latest|top|new)$/, "");
        }
        
        if (newPath !== window.location.pathname) {
          window.location.href = newPath;
        }
      });
    });
  }

  function addViewToggleListeners(sortBar) {
    sortBar.querySelectorAll(".toggle-option").forEach(option => {
      option.addEventListener("click", (e) => {
        e.preventDefault();
        
        // Update active state
        sortBar.querySelectorAll(".toggle-option").forEach(opt => {
          opt.classList.remove("active");
        });
        
        e.currentTarget.classList.add("active");
        
        // Toggle view mode
        const isCompact = e.currentTarget.querySelector(".d-icon-list");
        document.body.classList.toggle("reddit-compact-view", isCompact);
        
        // Store preference
        if (api.getCurrentUser()) {
          api.getCurrentUser().set("custom_fields.reddit_compact_view", isCompact);
        }
      });
    });
  }

});
