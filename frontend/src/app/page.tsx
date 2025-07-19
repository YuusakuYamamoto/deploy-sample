'use client'

import { useState, useEffect } from 'react'
import { UserList } from '@/components/UserList'
import { UserForm } from '@/components/UserForm'
import { HealthCheck } from '@/components/HealthCheck'

export default function Home() {
  const [users, setUsers] = useState([])
  const [loading, setLoading] = useState(true)

  const fetchUsers = async () => {
    try {
      const response = await fetch(`${process.env.NEXT_PUBLIC_API_URL}/users`)
      if (response.ok) {
        const data = await response.json()
        setUsers(data)
      }
    } catch (error) {
      console.error('Error fetching users:', error)
    } finally {
      setLoading(false)
    }
  }

  useEffect(() => {
    fetchUsers()
  }, [])

  const handleUserAdded = () => {
    fetchUsers()
  }

  return (
    <main className="min-h-screen bg-gray-50 py-8">
      <div className="max-w-6xl mx-auto px-4 sm:px-6 lg:px-8">
        <div className="text-center mb-8">
          <h1 className="text-3xl font-bold text-gray-900 mb-2">
            SDB Sample Application
          </h1>
          <p className="text-gray-600">
            Full-stack test application with Next.js, NestJS, and PostgreSQL
          </p>
        </div>

        <div className="grid grid-cols-1 lg:grid-cols-3 gap-8">
          <div className="lg:col-span-1">
            <div className="bg-white rounded-lg shadow p-6 mb-6">
              <h2 className="text-xl font-semibold mb-4">Backend Status</h2>
              <HealthCheck />
            </div>
            
            <div className="bg-white rounded-lg shadow p-6">
              <h2 className="text-xl font-semibold mb-4">Add User</h2>
              <UserForm onUserAdded={handleUserAdded} />
            </div>
          </div>

          <div className="lg:col-span-2">
            <div className="bg-white rounded-lg shadow p-6">
              <h2 className="text-xl font-semibold mb-4">Users</h2>
              <UserList users={users} loading={loading} onUserDeleted={fetchUsers} />
            </div>
          </div>
        </div>
      </div>
    </main>
  )
}