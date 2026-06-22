import { useQuery, useMutation, useQueryClient } from "@tanstack/react-query"
import { useAuthStore } from "@/lib/store/auth"
import { apiGetProfile, apiUpdateProfile } from "@/lib/api/user"

export function useProfile() {
  const { isAuthenticated } = useAuthStore()

  return useQuery({
    queryKey: ["profile"],
    queryFn: () => apiGetProfile(),
    enabled: isAuthenticated,
  })
}

export function useUpdateProfile() {
  const queryClient = useQueryClient()

  return useMutation({
    mutationFn: (formData: FormData) => apiUpdateProfile(formData),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ["profile"] })
    },
  })
}
