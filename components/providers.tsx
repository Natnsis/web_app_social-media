"use client"

import { QueryClient, QueryClientProvider } from "@tanstack/react-query"
import { useEffect, useState } from "react"
import { useAuthStore } from "@/lib/store/auth"

function AuthHydrator() {
    useEffect(() => {
        // Rehydrate Zustand persist store from localStorage on client mount
        useAuthStore.persist.rehydrate()
    }, [])
    return null
}

export function Providers({ children }: { children: React.ReactNode }) {
    const [queryClient] = useState(() => new QueryClient())
    return (
        <QueryClientProvider client={queryClient}>
            <AuthHydrator />
            {children}
        </QueryClientProvider>
    )
}
