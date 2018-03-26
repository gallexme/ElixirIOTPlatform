<template>
  <div class="hello">
    <h1>{{ msg }}</h1>
    <sui-button content="Like" icon="heart" label-position="left">
      <a
        is="sui-label"
        slot="label"
        basic
        pointing="right"
      >
        2,048
      </a>
    </sui-button>
  </div>
</template>

<script>
import { socket, channel } from "../socket"

export default {
  name: 'hello',
  data () {
    return {
      msg: 'Oh hi World'
    }
  },
  mounted() {
    channel.push("shout", {body: "Hello mounted"}, 10000);
  }
}
</script>

<!-- Add "scoped" attribute to limit CSS to this component only -->
<style scoped>
h1, h2 {
  font-weight: normal;
}

ul {
  list-style-type: none;
  padding: 0;
}

li {
  display: inline-block;
  margin: 0 10px;
}

a {
  color: #42b983;
}
</style>
