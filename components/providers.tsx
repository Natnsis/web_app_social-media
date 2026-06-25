"use client"

import { QueryClient, QueryClientProvider } from "@tanstack/react-query"
import { useEffect, useState } from "react"
import { ApiError } from "@/lib/api/client"
import { hydrateSession, refreshAccessToken } from "@/lib/auth/session"
import { useAuthStore } from "@/lib/store/auth"

function AuthHydrator() {
  useEffect(() => {
    const init = async () => {
      await useAuthStore.persist.rehydrate()
      const hydrated = await hydrateSession()
      if (!hydrated && !useAuthStore.getState().accessToken) {
        useAuthStore.getState().clearAuth()
      }
    }
    init()
  }, [])
  return null
}

function createQueryClient() {
  return new QueryClient({
    defaultOptions: {
      queries: {
        retry: (failureCount, error) => {
          if (error instanceof ApiError && error.status === 401) {
            return failureCount < 1
          }
          return failureCount < 2
        },
      },
      mutations: {
        retry: false,
      },
    },
  })
}

export function Providers({ children }: { children: React.ReactNode }) {
  const [queryClient] = useState(() => {
    const client = createQueryClient()

    client.getQueryCache().subscribe((event) => {
      if (event.type === "updated" && event.action.type === "failed") {
        const error = event.action.error
        if (error instanceof ApiError && error.status === 401) {
          void refreshAccessToken().then((token) => {
            if (token) client.invalidateQueries()
          })
        }
      }
    })

    return client
  })

  return (
    <QueryClientProvider client={queryClient}>
      <AuthHydrator />
      {children}
    </QueryClientProvider>
  )
}
