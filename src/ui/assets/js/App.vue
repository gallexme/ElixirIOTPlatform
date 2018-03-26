<template>
  <div id="app">
    <nav-bar/>
    <router-view></router-view>
  </div>
</template>


<script>
import NavBar from './components/NavBar'
import { socket, channel } from "./socket"

export default {
  name: 'app',
  components: { NavBar },
  mounted() {
    channel.push("shout", {body: "App mounted"}, 10000);
  }
}
</script>

<style>
#app {
  font-family: 'Avenir', Helvetica, Arial, sans-serif;
  -webkit-font-smoothing: antialiased;
  -moz-osx-font-smoothing: grayscale;
  text-align: center;
  color: #2c3e50;
  padding-top: 4em;
}
</style>
