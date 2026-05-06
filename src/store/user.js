import { defineStore } from 'pinia'

const useUserStore = defineStore('user', {
  state: () => ({
    token: localStorage.getItem('token') || '',
    userInfo: (() => {
      try {
        const userInfoStr = localStorage.getItem('userInfo');
        return userInfoStr ? JSON.parse(userInfoStr) : null;
      } catch (e) {
        console.error('解析 userInfo 失败:', e);
        return null;
      }
    })(),
    expire: localStorage.getItem('expire') || 0
  }),
  getters: {
    isLoggedIn: (state) => !!state.token,
    getToken: (state) => state.token,
    getUserInfo: (state) => state.userInfo
  },
  actions: {
    setUserInfo(userInfo) {
      this.userInfo = userInfo
      localStorage.setItem('userInfo', JSON.stringify(userInfo))
    },
    setToken(token, expire) {
      this.token = token
      this.expire = expire
      localStorage.setItem('token', token)
      localStorage.setItem('expire', expire)
    },
    logout() {
      this.token = ''
      this.userInfo = null
      this.expire = 0
      localStorage.removeItem('token')
      localStorage.removeItem('userInfo')
      localStorage.removeItem('expire')
    }
  }
})

export default useUserStore