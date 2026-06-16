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

interface AuthState {
  user: AuthUser | null
  isAuthenticated: boolean
  login: (email: string, password: string) => void
  logout: () => void
}

export const useAuthStore = create<AuthState>()(
  persist(
    (set) => ({
      user: null,
      isAuthenticated: false,
      login: (_email: string, _password: string) => {
        set({
          isAuthenticated: true,
          user: {
            id: "1",
            name: "Abebe Tesfaye",
            email: "abebe@beza.org",
            initials: "AT",
            role: "Global Administrator",
            org: "Beza International",
          },
        })
      },
      logout: () => set({ user: null, isAuthenticated: false }),
    }),
    {
      name: "faith-connect-auth",
      storage: createJSONStorage(() => localStorage),
      skipHydration: true,
    }
  )
)
