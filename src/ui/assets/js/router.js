
import Vue from 'vue'
import Router from 'vue-router'
/* Pages */
import Index from './pages/Index'
/* Components */
import Hello from './components/Hello'

Vue.use(Router)

export default new Router({
  routes: [
    {
      path: '/',
      name: 'Index',
      component: Index
    },
    {
      path: '/hello',
      name: 'Hello',
      component: Hello
    }
  ],
  linkActiveClass: "active", // active class for non-exact links.
  linkExactActiveClass: "active" // active class for *exact* links.
})
