import { useQuery, useMutation, useQueryClient } from "@tanstack/react-query"
import { useAuthStore } from "@/lib/store/auth"
import { apiGetProfile, apiUpdateProfile } from "@/lib/api/user"

export function useProfile() {
  const { accessToken, isAuthenticated } = useAuthStore()

  return useQuery({
    queryKey: ["profile"],
    queryFn: () => apiGetProfile(accessToken!),
    enabled: isAuthenticated && !!accessToken,
  })
}

export function useUpdateProfile() {
  const queryClient = useQueryClient()
  const { accessToken } = useAuthStore()

  return useMutation({
    mutationFn: (formData: FormData) => apiUpdateProfile(accessToken!, formData),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ["profile"] })
    },
  })
}
