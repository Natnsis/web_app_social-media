"use client"

import { useEffect, useState } from "react"
import { useRouter } from "next/navigation"
import { Eye, EyeOff } from "lucide-react"
import { cn } from "@/lib/utils"
import { Button } from "@/components/ui/button"
import { useAuthStore } from "@/lib/store/auth"
import { useMutation } from "@tanstack/react-query"
import {
  apiLogin,
  apiRegister,
  apiResendOtp,
  apiVerifyOtp,
  apiGoogleLogin,
  apiForgotPassword,
  apiResetPassword,
  apiChangePassword,
  apiAddPhone,
} from "@/lib/api/auth"
import {
  loginSchema,
  registerSchema,
  verifyOtpSchema,
  resendOtpSchema,
  forgotPasswordSchema,
  resetPasswordSchema,
  changePasswordSchema,
  addPhoneSchema,
} from "@/lib/validation/auth"

type AuthMode =
  | "login"
  | "signup"
  | "verify-otp"
  | "forgot-password"
  | "reset-password"
  | "change-password"
  | "add-phone"

export default function LoginPage() {
  const router = useRouter()
  const { setAuthData, isAuthenticated } = useAuthStore()
  const [mode, setMode] = useState<AuthMode>("login")

  // Form states
  const [emailOrPhone, setEmailOrPhone] = useState("")
  const [password, setPassword] = useState("")
  const [fullName, setFullName] = useState("")
  const [email, setEmail] = useState("")
  const [phoneNumber, setPhoneNumber] = useState("")
  const [otp, setOtp] = useState("")
  const [newPassword, setNewPassword] = useState("")
  const [confirmPassword, setConfirmPassword] = useState("")
  const [oldPassword, setOldPassword] = useState("")

  // Validation & API Errors
  const [validationErrors, setValidationErrors] = useState<
    Record<string, string>
  >({})
  const [apiError, setApiError] = useState<string | null>(null)
  const [apiSuccess, setApiSuccess] = useState<string | null>(null)

  const [checking, setChecking] = useState(true)

  useEffect(() => {
    const run = async () => {
      await useAuthStore.persist.rehydrate()
      if (useAuthStore.getState().isAuthenticated) {
        router.replace("/")
      } else {
        setChecking(false)
      }
    }
    run()
  }, [router])

  // Clear errors when changing modes
  const handleModeChange = (newMode: AuthMode) => {
    setMode(newMode)
    setValidationErrors({})
    setApiError(null)
    setApiSuccess(null)
  }

  // ── TanStack Query Mutations ──────────────────────────────────────────────────

  const loginMutation = useMutation({
    mutationFn: () => apiLogin(emailOrPhone, password),
    onSuccess: (res) => {
      setAuthData(res.data.accessToken, res.data.refreshToken)
      // Decode and console log the token as requested
      const base64Url = res.data.accessToken.split(".")[1]
      if (base64Url) {
        try {
          const base64 = base64Url.replace(/-/g, "+").replace(/_/g, "/")
          const jsonPayload = decodeURIComponent(
            atob(base64)
              .split("")
              .map((c) => "%" + ("00" + c.charCodeAt(0).toString(16)).slice(-2))
              .join("")
          )
          console.log(
            "SUCCESSFULLY LOGGED IN! Detokenized JWT payload:",
            JSON.parse(jsonPayload)
          )
        } catch (e) {
          console.error("Failed to decode token on console log", e)
        }
      }
      router.replace("/")
    },
    onError: (err: any) => {
      setApiError(err.message || "Login failed. Please try again.")
    },
  })

  const registerMutation = useMutation({
    mutationFn: () => apiRegister({ fullName, email, phoneNumber, password }),
    onSuccess: () => {
      setApiSuccess(
        "Registration successful! Verify your phone number with the OTP code."
      )
      // Automatically switch to verify OTP step with the registered phone number
      handleModeChange("verify-otp")
    },
    onError: (err: any) => {
      setApiError(err.message || "Registration failed. Please try again.")
    },
  })

  const verifyOtpMutation = useMutation({
    mutationFn: () => apiVerifyOtp(phoneNumber, otp),
    onSuccess: () => {
      setApiSuccess("OTP verified successfully! You can now log in.")
      handleModeChange("login")
    },
    onError: (err: any) => {
      setApiError(
        err.message || "OTP verification failed. Please check the code."
      )
    },
  })

  const resendOtpMutation = useMutation({
    mutationFn: () => apiResendOtp(phoneNumber),
    onSuccess: () => {
      setApiSuccess("OTP code resent successfully.")
    },
    onError: (err: any) => {
      setApiError(err.message || "Failed to resend OTP. Please try again.")
    },
  })

  const googleLoginMutation = useMutation({
    mutationFn: (idToken: string) => apiGoogleLogin(idToken),
    onSuccess: (res) => {
      setAuthData(res.data.accessToken, res.data.refreshToken)
      router.replace("/")
    },
    onError: (err: any) => {
      setApiError(err.message || "Google Login failed.")
    },
  })

  const forgotPasswordMutation = useMutation({
    mutationFn: () => apiForgotPassword(phoneNumber),
    onSuccess: () => {
      setApiSuccess("Forgot password request sent. Check for OTP code.")
      handleModeChange("reset-password")
    },
    onError: (err: any) => {
      setApiError(err.message || "Failed to process forgot password request.")
    },
  })

  const resetPasswordMutation = useMutation({
    mutationFn: () =>
      apiResetPassword({ phoneNumber, otp, newPassword, confirmPassword }),
    onSuccess: () => {
      setApiSuccess(
        "Password reset successfully! Log in with your new password."
      )
      handleModeChange("login")
    },
    onError: (err: any) => {
      setApiError(err.message || "Failed to reset password. Please try again.")
    },
  })

  const changePasswordMutation = useMutation({
    mutationFn: () => {
      const state = useAuthStore.getState()
      return apiChangePassword(
        oldPassword,
        newPassword,
        confirmPassword,
        state.accessToken || ""
      )
    },
    onSuccess: () => {
      setApiSuccess("Password changed successfully!")
      handleModeChange("login")
    },
    onError: (err: any) => {
      setApiError(
        err.message ||
          "Failed to change password. Please check your credentials."
      )
    },
  })

  const addPhoneMutation = useMutation({
    mutationFn: () => {
      const state = useAuthStore.getState()
      return apiAddPhone(phoneNumber, state.accessToken || "")
    },
    onSuccess: () => {
      setApiSuccess("Phone number added and OTP requested successfully!")
      handleModeChange("verify-otp")
    },
    onError: (err: any) => {
      setApiError(err.message || "Failed to add phone number.")
    },
  })

  // ── Form Submission Handlers ───────────────────────────────────────────────

  const handleLoginSubmit = (e: React.FormEvent) => {
    e.preventDefault()
    setValidationErrors({})
    setApiError(null)

    const validated = loginSchema.safeParse({ emailOrPhone, password })
    if (!validated.success) {
      const errors: Record<string, string> = {}
      validated.error.issues.forEach((issue) => {
        if (issue.path[0]) errors[issue.path[0].toString()] = issue.message
      })
      setValidationErrors(errors)
      return
    }
    loginMutation.mutate()
  }

  const handleRegisterSubmit = (e: React.FormEvent) => {
    e.preventDefault()
    setValidationErrors({})
    setApiError(null)

    const validated = registerSchema.safeParse({
      fullName,
      email,
      phoneNumber,
      password,
    })
    if (!validated.success) {
      const errors: Record<string, string> = {}
      validated.error.issues.forEach((issue) => {
        if (issue.path[0]) errors[issue.path[0].toString()] = issue.message
      })
      setValidationErrors(errors)
      return
    }
    registerMutation.mutate()
  }

  const handleVerifyOtpSubmit = (e: React.FormEvent) => {
    e.preventDefault()
    setValidationErrors({})
    setApiError(null)

    const validated = verifyOtpSchema.safeParse({ phoneNumber, otp })
    if (!validated.success) {
      const errors: Record<string, string> = {}
      validated.error.issues.forEach((issue) => {
        if (issue.path[0]) errors[issue.path[0].toString()] = issue.message
      })
      setValidationErrors(errors)
      return
    }
    verifyOtpMutation.mutate()
  }

  const handleResendOtp = () => {
    setValidationErrors({})
    setApiError(null)

    const validated = resendOtpSchema.safeParse({ phoneNumber })
    if (!validated.success) {
      const errors: Record<string, string> = {}
      validated.error.issues.forEach((issue) => {
        if (issue.path[0]) errors[issue.path[0].toString()] = issue.message
      })
      setValidationErrors(errors)
      return
    }
    resendOtpMutation.mutate()
  }

  const handleForgotPasswordSubmit = (e: React.FormEvent) => {
    e.preventDefault()
    setValidationErrors({})
    setApiError(null)

    const validated = forgotPasswordSchema.safeParse({ phoneNumber })
    if (!validated.success) {
      const errors: Record<string, string> = {}
      validated.error.issues.forEach((issue) => {
        if (issue.path[0]) errors[issue.path[0].toString()] = issue.message
      })
      setValidationErrors(errors)
      return
    }
    forgotPasswordMutation.mutate()
  }

  const handleResetPasswordSubmit = (e: React.FormEvent) => {
    e.preventDefault()
    setValidationErrors({})
    setApiError(null)

    const validated = resetPasswordSchema.safeParse({
      phoneNumber,
      otp,
      newPassword,
      confirmPassword,
    })
    if (!validated.success) {
      const errors: Record<string, string> = {}
      validated.error.issues.forEach((issue) => {
        if (issue.path[0]) errors[issue.path[0].toString()] = issue.message
      })
      setValidationErrors(errors)
      return
    }
    resetPasswordMutation.mutate()
  }

  const handleChangePasswordSubmit = (e: React.FormEvent) => {
    e.preventDefault()
    setValidationErrors({})
    setApiError(null)

    const validated = changePasswordSchema.safeParse({
      oldPassword,
      newPassword,
      confirmPassword,
    })
    if (!validated.success) {
      const errors: Record<string, string> = {}
      validated.error.issues.forEach((issue) => {
        if (issue.path[0]) errors[issue.path[0].toString()] = issue.message
      })
      setValidationErrors(errors)
      return
    }
    changePasswordMutation.mutate()
  }

  const handleAddPhoneSubmit = (e: React.FormEvent) => {
    e.preventDefault()
    setValidationErrors({})
    setApiError(null)

    const validated = addPhoneSchema.safeParse({ phoneNumber })
    if (!validated.success) {
      const errors: Record<string, string> = {}
      validated.error.issues.forEach((issue) => {
        if (issue.path[0]) errors[issue.path[0].toString()] = issue.message
      })
      setValidationErrors(errors)
      return
    }
    addPhoneMutation.mutate()
  }

  const handleGoogleLoginMock = () => {
    // Generate a mock OAuth id token for test execution
    googleLoginMutation.mutate("mock_id_token_123456")
  }

  if (checking) {
    return (
      <div className="flex h-screen items-center justify-center bg-background">
        <div className="size-8 animate-spin rounded-full border-4 border-primary border-t-transparent" />
      </div>
    )
  }

  const inputCls =
    "h-11 w-full rounded-xl border border-input bg-background px-4 text-sm text-foreground placeholder:text-muted-foreground outline-none transition focus:border-primary focus:ring-2 focus:ring-primary/30"

  function PasswordInput({
    value,
    onChange,
    placeholder,
    inputCls: extraCls,
  }: {
    value: string
    onChange: (e: React.ChangeEvent<HTMLInputElement>) => void
    placeholder?: string
    inputCls?: string
  }) {
    const [visible, setVisible] = useState(false)
    return (
      <div className="relative">
        <input
          type={visible ? "text" : "password"}
          placeholder={placeholder ?? "••••••••"}
          value={value}
          onChange={onChange}
          className={cn(inputCls, "pr-10", extraCls)}
        />
        <button
          type="button"
          tabIndex={-1}
          onClick={() => setVisible((v) => !v)}
          className="absolute top-1/2 right-3 -translate-y-1/2 text-muted-foreground transition-colors hover:text-foreground"
        >
          {visible ? <EyeOff className="size-4" /> : <Eye className="size-4" />}
        </button>
      </div>
    )
  }

  const isLoading =
    loginMutation.isPending ||
    registerMutation.isPending ||
    verifyOtpMutation.isPending ||
    forgotPasswordMutation.isPending ||
    resetPasswordMutation.isPending ||
    changePasswordMutation.isPending ||
    addPhoneMutation.isPending ||
    resendOtpMutation.isPending

  return (
    <div className="flex min-h-screen bg-background">
      <div className="relative hidden flex-col justify-between overflow-hidden lg:flex lg:w-[50%] xl:w-[50%]">
        <div
          className="absolute inset-0 bg-cover bg-center"
          style={{ backgroundImage: "url('/login.jpg')" }}
        />

        <div className="absolute inset-0 bg-gradient-to-r from-black/80 via-black/60 to-black/30" />
        <div className="relative z-10 flex justify-center px-10 pt-10">
          <h1 className="text-xl font-bold text-white">FaithConnect</h1>
        </div>

        <div className="relative z-10 space-y-6 px-10 pb-16">
          <div className="space-y-4">
            <h1 className="text-2xl leading-tight font-bold text-white xl:text-5xl">
              One platform for worship,
              <br />
              community, and
              <br />
              stewardship.
            </h1>
            <p className="max-w-md text-sm leading-relaxed text-white/70">
              This platform empowers African faith communities. Connect with
              your church, participate in community growth, and manage your
              contributions with modern precision.
            </p>
          </div>
          <div className="flex gap-8 pt-2">
            <div>
              <p className="text-2xl font-bold text-white">500+</p>
              <p className="text-xs text-white/60">Partner Churches</p>
            </div>
            <div>
              <p className="text-2xl font-bold text-white">50k+</p>
              <p className="text-xs text-white/60">Active Members</p>
            </div>
          </div>
        </div>

        <div className="relative z-10 px-10 pb-6">
          <p className="text-[11px] text-white/40">
            © 2026 FaithConnect. Ethiopian Protestant Union
          </p>
        </div>
      </div>

      <div className="flex flex-1 flex-col items-center justify-center px-6 py-10 lg:bg-card">
        <div className="mb-8 flex flex-col items-center gap-3 lg:hidden">
          <h1 className="text-2xl font-bold tracking-tight text-foreground">
            Faith<span className="text-primary">Connect</span>
          </h1>
        </div>

        <div className="w-full max-w-[360px] space-y-6">
          {/* Header */}
          <div>
            <h2 className="hidden text-center text-xl font-bold text-foreground md:block">
              {mode === "login" && "Welcome Back"}
              {mode === "signup" && "Create Account"}
              {mode === "verify-otp" && "Verify OTP"}
              {mode === "forgot-password" && "Forgot Password"}
              {mode === "reset-password" && "Reset Password"}
              {mode === "change-password" && "Change Password"}
              {mode === "add-phone" && "Add Phone Number"}
            </h2>
            <p className="mt-1 text-center text-sm text-muted-foreground">
              {mode === "login" && "Sign in to your FaithConnect account"}
              {mode === "signup" && "Join the FaithConnect community today"}
              {mode === "verify-otp" &&
                "Enter the 6-digit code sent to your phone"}
              {mode === "forgot-password" &&
                "Enter your phone number to receive an OTP code"}
              {mode === "reset-password" &&
                "Enter your OTP code and set a new password"}
              {mode === "change-password" &&
                "Update your account password securely"}
              {mode === "add-phone" &&
                "Verify your phone number to secure your account"}
            </p>
          </div>

          {/* Feedback Messages */}
          {apiError && (
            <div className="rounded-xl border border-red-500/20 bg-red-500/10 p-3 text-center text-xs text-red-400">
              {apiError}
            </div>
          )}

          {apiSuccess && (
            <div className="rounded-xl border border-green-500/20 bg-green-500/10 p-3 text-center text-xs text-green-400">
              {apiSuccess}
            </div>
          )}

          {/* Form container */}
          <div className="space-y-4">
            {/* Mode: Login */}
            {mode === "login" && (
              <form onSubmit={handleLoginSubmit} className="space-y-3">
                <div className="space-y-1.5">
                  <label className="text-xs font-medium text-muted-foreground">
                    Email or Phone Number
                  </label>
                  <input
                    type="text"
                    placeholder="user@example.com or +251912345678"
                    value={emailOrPhone}
                    onChange={(e) => setEmailOrPhone(e.target.value)}
                    className={inputCls}
                  />
                  {validationErrors.emailOrPhone && (
                    <p className="text-[11px] text-red-400">
                      {validationErrors.emailOrPhone}
                    </p>
                  )}
                </div>

                <div className="space-y-1.5">
                  <div className="flex items-center justify-between">
                    <label className="text-xs font-medium text-muted-foreground">
                      Password
                    </label>
                    <button
                      type="button"
                      onClick={() => handleModeChange("forgot-password")}
                      className="text-[11px] text-primary hover:underline"
                    >
                      Forgot password?
                    </button>
                  </div>
                  <PasswordInput
                    value={password}
                    onChange={(e) => setPassword(e.target.value)}
                  />
                  {validationErrors.password && (
                    <p className="text-[11px] text-red-400">
                      {validationErrors.password}
                    </p>
                  )}
                </div>

                <Button
                  type="submit"
                  disabled={isLoading}
                  className="mt-2 h-11 w-full rounded-xl"
                >
                  {isLoading ? "Signing In..." : "Sign In →"}
                </Button>
              </form>
            )}

            {/* Mode: Signup */}
            {mode === "signup" && (
              <form onSubmit={handleRegisterSubmit} className="space-y-3">
                <div className="space-y-1.5">
                  <label className="text-xs font-medium text-muted-foreground">
                    Full Name
                  </label>
                  <input
                    type="text"
                    placeholder="John Doe"
                    value={fullName}
                    onChange={(e) => setFullName(e.target.value)}
                    className={inputCls}
                  />
                  {validationErrors.fullName && (
                    <p className="text-[11px] text-red-400">
                      {validationErrors.fullName}
                    </p>
                  )}
                </div>

                <div className="space-y-1.5">
                  <label className="text-xs font-medium text-muted-foreground">
                    Email Address
                  </label>
                  <input
                    type="email"
                    placeholder="john@example.com"
                    value={email}
                    onChange={(e) => setEmail(e.target.value)}
                    className={inputCls}
                  />
                  {validationErrors.email && (
                    <p className="text-[11px] text-red-400">
                      {validationErrors.email}
                    </p>
                  )}
                </div>

                <div className="space-y-1.5">
                  <label className="text-xs font-medium text-muted-foreground">
                    Phone Number
                  </label>
                  <input
                    type="text"
                    placeholder="+251912345678"
                    value={phoneNumber}
                    onChange={(e) => setPhoneNumber(e.target.value)}
                    className={inputCls}
                  />
                  {validationErrors.phoneNumber && (
                    <p className="text-[11px] text-red-400">
                      {validationErrors.phoneNumber}
                    </p>
                  )}
                </div>

                <div className="space-y-1.5">
                  <label className="text-xs font-medium text-muted-foreground">
                    Password
                  </label>
                  <PasswordInput
                    value={password}
                    onChange={(e) => setPassword(e.target.value)}
                  />
                  {validationErrors.password && (
                    <p className="text-[11px] text-red-400">
                      {validationErrors.password}
                    </p>
                  )}
                </div>

                <Button
                  type="submit"
                  disabled={isLoading}
                  className="mt-2 h-11 w-full rounded-xl"
                >
                  {isLoading ? "Creating Account..." : "Create Account →"}
                </Button>
              </form>
            )}

            {/* Mode: Verify OTP */}
            {mode === "verify-otp" && (
              <form onSubmit={handleVerifyOtpSubmit} className="space-y-3">
                <div className="space-y-1.5">
                  <label className="text-xs font-medium text-muted-foreground">
                    Phone Number
                  </label>
                  <input
                    type="text"
                    placeholder="+251912345678"
                    value={phoneNumber}
                    onChange={(e) => setPhoneNumber(e.target.value)}
                    className={inputCls}
                  />
                  {validationErrors.phoneNumber && (
                    <p className="text-[11px] text-red-400">
                      {validationErrors.phoneNumber}
                    </p>
                  )}
                </div>

                <div className="space-y-1.5">
                  <label className="text-xs font-medium text-muted-foreground">
                    6-Digit OTP
                  </label>
                  <input
                    type="text"
                    placeholder="123456"
                    maxLength={6}
                    value={otp}
                    onChange={(e) => setOtp(e.target.value)}
                    className={inputCls}
                  />
                  {validationErrors.otp && (
                    <p className="text-[11px] text-red-400">
                      {validationErrors.otp}
                    </p>
                  )}
                </div>

                <div className="flex gap-2">
                  <Button
                    type="button"
                    variant="outline"
                    onClick={handleResendOtp}
                    disabled={isLoading}
                    className="h-11 flex-1 rounded-xl border-border text-foreground hover:bg-accent"
                  >
                    Resend OTP
                  </Button>
                  <Button
                    type="submit"
                    disabled={isLoading}
                    className="h-11 flex-1 rounded-xl"
                  >
                    {isLoading ? "Verifying..." : "Verify OTP"}
                  </Button>
                </div>
              </form>
            )}

            {/* Mode: Forgot Password */}
            {mode === "forgot-password" && (
              <form onSubmit={handleForgotPasswordSubmit} className="space-y-3">
                <div className="space-y-1.5">
                  <label className="text-xs font-medium text-muted-foreground">
                    Phone Number
                  </label>
                  <input
                    type="text"
                    placeholder="+251912345678"
                    value={phoneNumber}
                    onChange={(e) => setPhoneNumber(e.target.value)}
                    className={inputCls}
                  />
                  {validationErrors.phoneNumber && (
                    <p className="text-[11px] text-red-400">
                      {validationErrors.phoneNumber}
                    </p>
                  )}
                </div>

                <Button
                  type="submit"
                  disabled={isLoading}
                  className="mt-2 h-11 w-full rounded-xl"
                >
                  {isLoading ? "Requesting OTP..." : "Request OTP"}
                </Button>
              </form>
            )}

            {/* Mode: Reset Password */}
            {mode === "reset-password" && (
              <form onSubmit={handleResetPasswordSubmit} className="space-y-3">
                <div className="space-y-1.5">
                  <label className="text-xs font-medium text-muted-foreground">
                    Phone Number
                  </label>
                  <input
                    type="text"
                    placeholder="+251912345678"
                    value={phoneNumber}
                    onChange={(e) => setPhoneNumber(e.target.value)}
                    className={inputCls}
                  />
                  {validationErrors.phoneNumber && (
                    <p className="text-[11px] text-red-400">
                      {validationErrors.phoneNumber}
                    </p>
                  )}
                </div>

                <div className="space-y-1.5">
                  <label className="text-xs font-medium text-muted-foreground">
                    6-Digit OTP
                  </label>
                  <input
                    type="text"
                    placeholder="123456"
                    maxLength={6}
                    value={otp}
                    onChange={(e) => setOtp(e.target.value)}
                    className={inputCls}
                  />
                  {validationErrors.otp && (
                    <p className="text-[11px] text-red-400">
                      {validationErrors.otp}
                    </p>
                  )}
                </div>

                <div className="space-y-1.5">
                  <label className="text-xs font-medium text-muted-foreground">
                    New Password
                  </label>
                  <PasswordInput
                    value={newPassword}
                    onChange={(e) => setNewPassword(e.target.value)}
                  />
                  {validationErrors.newPassword && (
                    <p className="text-[11px] text-red-400">
                      {validationErrors.newPassword}
                    </p>
                  )}
                </div>

                <div className="space-y-1.5">
                  <label className="text-xs font-medium text-muted-foreground">
                    Confirm New Password
                  </label>
                  <PasswordInput
                    value={confirmPassword}
                    onChange={(e) => setConfirmPassword(e.target.value)}
                  />
                  {validationErrors.confirmPassword && (
                    <p className="text-[11px] text-red-400">
                      {validationErrors.confirmPassword}
                    </p>
                  )}
                </div>

                <Button
                  type="submit"
                  disabled={isLoading}
                  className="mt-2 h-11 w-full rounded-xl"
                >
                  {isLoading ? "Resetting Password..." : "Reset Password"}
                </Button>
              </form>
            )}

            {/* Mode: Change Password */}
            {mode === "change-password" && (
              <form onSubmit={handleChangePasswordSubmit} className="space-y-3">
                <div className="space-y-1.5">
                  <label className="text-xs font-medium text-muted-foreground">
                    Old Password
                  </label>
                  <PasswordInput
                    value={oldPassword}
                    onChange={(e) => setOldPassword(e.target.value)}
                  />
                  {validationErrors.oldPassword && (
                    <p className="text-[11px] text-red-400">
                      {validationErrors.oldPassword}
                    </p>
                  )}
                </div>

                <div className="space-y-1.5">
                  <label className="text-xs font-medium text-muted-foreground">
                    New Password
                  </label>
                  <PasswordInput
                    value={newPassword}
                    onChange={(e) => setNewPassword(e.target.value)}
                  />
                  {validationErrors.newPassword && (
                    <p className="text-[11px] text-red-400">
                      {validationErrors.newPassword}
                    </p>
                  )}
                </div>

                <div className="space-y-1.5">
                  <label className="text-xs font-medium text-muted-foreground">
                    Confirm New Password
                  </label>
                  <PasswordInput
                    value={confirmPassword}
                    onChange={(e) => setConfirmPassword(e.target.value)}
                  />
                  {validationErrors.confirmPassword && (
                    <p className="text-[11px] text-red-400">
                      {validationErrors.confirmPassword}
                    </p>
                  )}
                </div>

                <Button
                  type="submit"
                  disabled={isLoading}
                  className="mt-2 h-11 w-full rounded-xl"
                >
                  {isLoading ? "Changing Password..." : "Change Password"}
                </Button>
              </form>
            )}

            {/* Mode: Add Phone */}
            {mode === "add-phone" && (
              <form onSubmit={handleAddPhoneSubmit} className="space-y-3">
                <div className="space-y-1.5">
                  <label className="text-xs font-medium text-muted-foreground">
                    Phone Number
                  </label>
                  <input
                    type="text"
                    placeholder="+251912345678"
                    value={phoneNumber}
                    onChange={(e) => setPhoneNumber(e.target.value)}
                    className={inputCls}
                  />
                  {validationErrors.phoneNumber && (
                    <p className="text-[11px] text-red-400">
                      {validationErrors.phoneNumber}
                    </p>
                  )}
                </div>

                <Button
                  type="submit"
                  disabled={isLoading}
                  className="mt-2 h-11 w-full rounded-xl"
                >
                  {isLoading ? "Adding Phone..." : "Add Phone Number"}
                </Button>
              </form>
            )}
          </div>

          {/* Social / Extra Options */}
          {mode === "login" && (
            <>
              <div className="relative flex items-center gap-3">
                <div className="h-px flex-1 bg-border" />
                <span className="text-[11px] text-muted-foreground">
                  OR SIGN IN WITH
                </span>
                <div className="h-px flex-1 bg-border" />
              </div>

              <div className="w-full">
                {/* Standard Google brand styled button (mimicking SDK theme) */}
                <button
                  type="button"
                  onClick={handleGoogleLoginMock}
                  disabled={isLoading}
                  className="flex h-11 w-full items-center justify-center gap-3 rounded-xl border border-[#dadce0] bg-white text-sm font-medium text-[#3c4043] shadow-sm transition-colors hover:border-[#c3c6ca] hover:bg-[#f8f9fa]"
                >
                  <svg
                    width="18"
                    height="18"
                    viewBox="0 0 24 24"
                    className="shrink-0"
                  >
                    <path
                      fill="#4285F4"
                      d="M22.56 12.25c0-.78-.07-1.53-.2-2.25H12v4.26h5.92c-.26 1.37-1.04 2.53-2.21 3.31v2.77h3.57c2.08-1.92 3.28-4.74 3.28-8.09z"
                    />
                    <path
                      fill="#34A853"
                      d="M12 23c2.97 0 5.46-.98 7.28-2.66l-3.57-2.77c-.98.66-2.23 1.06-3.71 1.06-2.86 0-5.29-1.93-6.16-4.53H2.18v2.84C3.99 20.53 7.7 23 12 23z"
                    />
                    <path
                      fill="#FBBC05"
                      d="M5.84 14.09c-.22-.66-.35-1.36-.35-2.09s.13-1.43.35-2.09V7.07H2.18C1.43 8.55 1 10.22 1 12s.43 3.45 1.18 4.93l2.85-2.22.81-.62z"
                    />
                    <path
                      fill="#EA4335"
                      d="M12 5.38c1.62 0 3.06.56 4.21 1.64l3.15-3.15C17.45 2.09 14.97 1 12 1 7.7 1 3.99 3.47 2.18 7.07l3.66 2.84c.87-2.6 3.3-4.53 6.16-4.53z"
                    />
                  </svg>
                  Sign in with Google
                </button>
              </div>
            </>
          )}

          {/* Mode toggles */}
          <div className="flex flex-col gap-2 text-center text-xs text-muted-foreground">
            {mode === "login" && (
              <>
                <p>
                  Don&apos;t have an account?{" "}
                  <button
                    type="button"
                    onClick={() => handleModeChange("signup")}
                    className="font-medium text-primary hover:underline"
                  >
                    Request Access
                  </button>
                </p>
                <p className="text-[11px] text-muted-foreground/50">
                  Need to change password?{" "}
                  <button
                    type="button"
                    onClick={() => handleModeChange("change-password")}
                    className="text-primary hover:underline"
                  >
                    Change Password
                  </button>
                </p>
              </>
            )}

            {mode === "signup" && (
              <p>
                Already have an account?{" "}
                <button
                  type="button"
                  onClick={() => handleModeChange("login")}
                  className="font-medium text-primary hover:underline"
                >
                  Sign In
                </button>
              </p>
            )}

            {mode !== "login" && mode !== "signup" && (
              <button
                type="button"
                onClick={() => handleModeChange("login")}
                className="font-medium text-primary hover:underline"
              >
                ← Back to Sign In
              </button>
            )}
          </div>

          <div className="flex justify-center gap-4 pt-2 text-[10px] text-muted-foreground/50">
            <button className="hover:text-foreground/60">Privacy</button>
            <button className="hover:text-foreground/60">Terms</button>
            <button className="hover:text-foreground/60">
              Contact Support
            </button>
          </div>
        </div>
      </div>
    </div>
  )
}
