import { z } from "zod"

export const loginResponseSchema = z.object({
  success: z.boolean(),
  data: z.object({
    accessToken: z.string(),
    refreshToken: z.string(),
    roles: z.array(z.string()).optional(),
  }),
  timestamp: z.string().optional(),
})

export const authResponseSchema = z.object({
  success: z.boolean(),
  message: z.string().optional(),
  data: z.unknown().optional(),
  timestamp: z.string().optional(),
})

export type LoginResponse = z.infer<typeof loginResponseSchema>
export type AuthResponse = z.infer<typeof authResponseSchema>

export const loginRequestSchema = z.object({
  emailOrPhone: z.string().min(1),
  password: z.string().min(1),
})

export const registerRequestSchema = z.object({
  fullName: z.string().min(2),
  email: z.string().email(),
  phoneNumber: z.string().min(10),
  password: z.string().min(6),
})

export const refreshRequestSchema = z.object({
  refreshToken: z.string().min(1),
})

export const googleLoginRequestSchema = z.object({
  idToken: z.string().min(1),
})

export const otpResendRequestSchema = z.object({
  phoneNumber: z.string().min(10),
})

export const otpVerifyRequestSchema = z.object({
  phoneNumber: z.string().min(10),
  otp: z.string().length(6),
})

export const changePasswordRequestSchema = z.object({
  oldPassword: z.string().min(1),
  newPassword: z.string().min(6),
  confirmPassword: z.string().min(6),
})

export const forgotPasswordRequestSchema = z.object({
  phoneNumber: z.string().min(10),
})

export const resetPasswordRequestSchema = z.object({
  phoneNumber: z.string().min(10),
  otp: z.string().length(6),
  newPassword: z.string().min(6),
  confirmPassword: z.string().min(6),
})

export const addPhoneRequestSchema = z.object({
  phoneNumber: z.string().min(10),
})
