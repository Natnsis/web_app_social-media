"use client"

import { useQuery, useMutation, useQueryClient } from "@tanstack/react-query"
import {
  apiGetCampaigns,
  apiGetCampaign,
  apiCreateCampaign,
  apiUpdateCampaign,
  apiDeleteCampaign,
} from "@/lib/api/campaigns"
import type { CreateCampaignPayload } from "@/lib/api/campaigns"

export function useCampaigns(page = 1, limit = 20) {
  return useQuery({
    queryKey: ["campaigns", page, limit],
    queryFn: () => apiGetCampaigns(page, limit),
  })
}

export function useCampaign(id: string) {
  return useQuery({
    queryKey: ["campaign", id],
    queryFn: () => apiGetCampaign(id),
    enabled: !!id,
  })
}

export function useCreateCampaign() {
  const qc = useQueryClient()
  return useMutation({
    mutationFn: (payload: CreateCampaignPayload) => apiCreateCampaign(payload),
    onSuccess: () => {
      qc.invalidateQueries({ queryKey: ["campaigns"] })
    },
  })
}

export function useUpdateCampaign(id: string) {
  const qc = useQueryClient()
  return useMutation({
    mutationFn: (payload: Partial<CreateCampaignPayload>) => apiUpdateCampaign(id, payload),
    onSuccess: () => {
      qc.invalidateQueries({ queryKey: ["campaigns"] })
      qc.invalidateQueries({ queryKey: ["campaign", id] })
    },
  })
}

export function useDeleteCampaign() {
  const qc = useQueryClient()
  return useMutation({
    mutationFn: (id: string) => apiDeleteCampaign(id),
    onSuccess: () => {
      qc.invalidateQueries({ queryKey: ["campaigns"] })
    },
  })
}
