'use client'

import { useState, useEffect } from 'react'

export function HealthCheck() {
  const [status, setStatus] = useState<'loading' | 'healthy' | 'error'>('loading')
  const [message, setMessage] = useState('')

  useEffect(() => {
    const checkHealth = async () => {
      try {
        const response = await fetch(`${process.env.NEXT_PUBLIC_API_URL}/health`)
        if (response.ok) {
          const data = await response.json()
          setStatus('healthy')
          setMessage(`Backend is healthy - ${data.timestamp}`)
        } else {
          setStatus('error')
          setMessage('Backend is not responding')
        }
      } catch (error) {
        setStatus('error')
        setMessage('Failed to connect to backend')
      }
    }

    checkHealth()
    const interval = setInterval(checkHealth, 30000) // Check every 30 seconds

    return () => clearInterval(interval)
  }, [])

  return (
    <div className="flex items-center space-x-2">
      <div
        className={`w-3 h-3 rounded-full ${
          status === 'loading'
            ? 'bg-yellow-400'
            : status === 'healthy'
            ? 'bg-green-400'
            : 'bg-red-400'
        }`}
      />
      <span className="text-sm text-gray-600">
        {status === 'loading' ? 'Checking...' : message}
      </span>
    </div>
  )
}