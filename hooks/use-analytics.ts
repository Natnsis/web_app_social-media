"use client"

import { useQuery } from "@tanstack/react-query"
import { useAuthStore } from "@/lib/store/auth"
import { apiGetChurchAnalytics } from "@/lib/api/churches"
import { useProfile } from "./use-profile"

export function useChurchAnalytics(range: "week" | "month" | "year" = "month") {
  const { isAuthenticated } = useAuthStore()
  const { data: profileData } = useProfile()
  const churchId = profileData?.data?.church?.id

  return useQuery({
    queryKey: ["church-analytics", churchId, range],
    queryFn: () => apiGetChurchAnalytics(churchId!),
    enabled: isAuthenticated && !!churchId,
  })
}
