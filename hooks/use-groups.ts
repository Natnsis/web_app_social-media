"use client"

import { useQuery } from "@tanstack/react-query"
import { apiGetGroups } from "@/lib/api/groups"

export function useGroups(enabled = true) {
  return useQuery({
    queryKey: ["groups"],
    queryFn: apiGetGroups,
    enabled,
  })
}
