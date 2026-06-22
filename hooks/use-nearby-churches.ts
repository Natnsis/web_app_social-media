"use client"

import { useQuery, useMutation, useQueryClient } from "@tanstack/react-query"
import { apiGetNearbyChurches, apiFollowChurch, apiUnfollowChurch } from "@/lib/api/churches"

export function useNearbyChurches(lat: number, lng: number, radiusKm: number) {
  return useQuery({
    queryKey: ["nearby-churches", lat, lng, radiusKm],
    queryFn: () => apiGetNearbyChurches(lat, lng, radiusKm),
    enabled: !!lat && !!lng,
  })
}

export function useToggleFollowChurch() {
  const qc = useQueryClient()
  return useMutation({
    mutationFn: ({ id, following }: { id: string; following: boolean }) =>
      following ? apiUnfollowChurch(id) : apiFollowChurch(id),
    onSuccess: () => {
      qc.invalidateQueries({ queryKey: ["nearby-churches"] })
    },
  })
}
