import { z } from "zod"

export const loginSchema = z.object({
  emailOrPhone: z.string().min(1, "Email or Phone number is required"),
  password: z.string().min(4, "Password must be at least 4 characters"),
})

export const registerSchema = z.object({
  fullName: z.string().min(2, "Full Name must be at least 2 characters"),
  email: z.string().email("Invalid email address"),
  phoneNumber: z
    .string()
    .min(10, "Phone number must be at least 10 characters")
    .regex(/^\+?[1-9]\d{1,14}$/, "Phone number must be in E.164 format (e.g. +251912345678)"),
  password: z.string().min(6, "Password must be at least 6 characters"),
})

export const resendOtpSchema = z.object({
  phoneNumber: z.string().min(10, "Phone number is required"),
})

export const verifyOtpSchema = z.object({
  phoneNumber: z.string().min(10, "Phone number is required"),
  otp: z.string().length(6, "OTP must be exactly 6 digits"),
})

export const forgotPasswordSchema = z.object({
  phoneNumber: z.string().min(10, "Phone number is required"),
})

export const resetPasswordSchema = z
  .object({
    phoneNumber: z.string().min(10, "Phone number is required"),
    otp: z.string().length(6, "OTP must be exactly 6 digits"),
    newPassword: z.string().min(6, "Password must be at least 6 characters"),
    confirmPassword: z.string().min(6, "Confirm password is required"),
  })
  .refine((data) => data.newPassword === data.confirmPassword, {
    message: "Passwords do not match",
    path: ["confirmPassword"],
  })

export const changePasswordSchema = z
  .object({
    oldPassword: z.string().min(1, "Old password is required"),
    newPassword: z.string().min(6, "New password must be at least 6 characters"),
    confirmPassword: z.string().min(6, "Confirm password is required"),
  })
  .refine((data) => data.newPassword === data.confirmPassword, {
    message: "Passwords do not match",
    path: ["confirmPassword"],
  })

export const addPhoneSchema = z.object({
  phoneNumber: z.string().min(10, "Phone number is required"),
})
