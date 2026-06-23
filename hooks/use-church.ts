"use client"

import { useQuery } from "@tanstack/react-query"
import { apiGetChurch } from "@/lib/api/churches"

export function useChurch(id: string | null) {
  return useQuery({
    queryKey: ["church", id],
    queryFn: () => apiGetChurch(id!),
    enabled: !!id,
  })
}
