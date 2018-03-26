<template lang="html">
  <b-navbar toggleable="md" type="dark" fixed="top" variant="dark">

    <b-navbar-toggle target="nav_collapse"></b-navbar-toggle>

    <b-navbar-brand href="#">El'IOT'iX</b-navbar-brand>

    <b-collapse is-nav id="nav_collapse">

      <b-navbar-nav>
        <router-link to="/" is="b-nav-item" href="#">Home</router-link>
        <router-link to="/hello" is="b-nav-item" href="#">Hello</router-link>
      </b-navbar-nav>

      <!-- Right aligned nav items -->
      <b-navbar-nav class="ml-auto">

        <b-nav-item-dropdown right>
          <!-- Using button-content slot -->
          <template slot="button-content">
            <em>User</em>
          </template>
          <b-dropdown-item href="#">Profile</b-dropdown-item>
          <b-dropdown-item href="#">Signout</b-dropdown-item>
        </b-nav-item-dropdown>
      </b-navbar-nav>

    </b-collapse>
  </b-navbar>
</template>

<script>
export default {
}
</script>

<style lang="css">
  .ui.inverted.menu {
      border: 0 solid transparent;
      background: #252627df;
      -webkit-box-shadow: none;
      box-shadow: none;
  }

  .ui.fixed.menu .toc.item {
    display: none;
  }

  @media only screen and (max-width: 700px) {
    .ui.fixed.menu .item.only {
      display: none !important;
    }
    .ui.fixed.menu .toc.item {
      display: block;
    }
  }
</style>
