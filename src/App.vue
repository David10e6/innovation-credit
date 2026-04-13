<script setup>
import { computed } from 'vue'
import { useRoute } from 'vue-router'
import Layout from './components/Layout.vue'

const route = useRoute()

// 登录页不需要布局
const isLoginPage = computed(() => {
  return route.path === '/login'
})
</script>

<template>
  <template v-if="isLoginPage">
    <router-view />
  </template>
  <template v-else>
    <Layout />
  </template>
</template>

<style>
* {
  margin: 0;
  padding: 0;
  box-sizing: border-box;
}

html, body, #app {
  height: 100%;
  width: 100%;
  overflow: hidden;
}

body {
  font-family: Arial, sans-serif;
  background-color: #f5f7fa;
}
</style>
