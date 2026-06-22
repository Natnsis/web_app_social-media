"use client"

import { useState, useEffect } from "react"

const DEFAULT_LOCATION = { latitude: 9.0320, longitude: 38.7469 }

interface GeolocationState {
  latitude: number
  longitude: number
  error: string | null
  loading: boolean
}

export function useGeolocation() {
  const [state, setState] = useState<GeolocationState>({
    latitude: DEFAULT_LOCATION.latitude,
    longitude: DEFAULT_LOCATION.longitude,
    error: null,
    loading: true,
  })

  useEffect(() => {
    if (!navigator.geolocation) {
      setState((prev) => ({ ...prev, error: "Geolocation not supported", loading: false }))
      return
    }

    navigator.geolocation.getCurrentPosition(
      (position) => {
        setState({
          latitude: position.coords.latitude,
          longitude: position.coords.longitude,
          error: null,
          loading: false,
        })
      },
      () => {
        setState((prev) => ({
          ...prev,
          error: "Using default location",
          loading: false,
        }))
      },
      { enableHighAccuracy: false, timeout: 10000 }
    )
  }, [])

  return state
}
