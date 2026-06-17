import { create } from "zustand"
import { persist, createJSONStorage } from "zustand/middleware"

export interface AuthUser {
  id: string
  name: string
  email: string
  initials: string
  role: string
  org: string
}

const users: Record<string, { password: string; user: AuthUser }> = {
  "user@gmail.com": {
    password: "1234",
    user: {
      id: "1",
      name: "Abebe Tesfaye",
      email: "user@gmail.com",
      initials: "AT",
      role: "Church Owner",
      org: "Beza International",
    },
  },
  user2: {
    password: "1234",
    user: {
      id: "2",
      name: "Biruk Lemma",
      email: "user2",
      initials: "BL",
      role: "Follower",
      org: "Beza International",
    },
  },
}

interface AuthState {
  user: AuthUser | null
  isAuthenticated: boolean
  loginError: string | null
  login: (email: string, password: string) => boolean
  logout: () => void
  clearError: () => void
}

export const useAuthStore = create<AuthState>()(
  persist(
    (set) => ({
      user: null,
      isAuthenticated: false,
      loginError: null,
      login: (email: string, password: string) => {
        const entry = users[email]
        if (!entry || entry.password !== password) {
          set({ loginError: "Invalid email or password" })
          return false
        }
        set({
          isAuthenticated: true,
          user: entry.user,
          loginError: null,
        })
        return true
      },
      logout: () => set({ user: null, isAuthenticated: false, loginError: null }),
      clearError: () => set({ loginError: null }),
    }),
    {
      name: "faith-connect-auth",
      storage: createJSONStorage(() => localStorage),
      skipHydration: true,
    }
  )
)
