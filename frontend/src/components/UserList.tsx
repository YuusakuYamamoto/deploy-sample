'use client'

import { useState } from 'react'

interface User {
  id: number
  email: string
  name: string | null
  createdAt: string
  posts: any[]
}

interface UserListProps {
  users: User[]
  loading: boolean
  onUserDeleted: () => void
}

export function UserList({ users, loading, onUserDeleted }: UserListProps) {
  const [deletingId, setDeletingId] = useState<number | null>(null)

  const handleDelete = async (id: number) => {
    setDeletingId(id)
    try {
      const response = await fetch(`/api/users/${id}`, {
        method: 'DELETE',
      })

      if (response.ok) {
        onUserDeleted()
      } else {
        alert('Failed to delete user')
      }
    } catch (error) {
      alert('Failed to connect to backend')
    } finally {
      setDeletingId(null)
    }
  }

  if (loading) {
    return (
      <div className="text-center py-8">
        <div className="animate-spin rounded-full h-8 w-8 border-b-2 border-indigo-600 mx-auto"></div>
        <p className="mt-2 text-gray-600">Loading users...</p>
      </div>
    )
  }

  if (users.length === 0) {
    return (
      <div className="text-center py-8">
        <p className="text-gray-600">No users found. Add a user to get started.</p>
      </div>
    )
  }

  return (
    <div className="space-y-4">
      {users.map((user) => (
        <div key={user.id} className="border border-gray-200 rounded-lg p-4">
          <div className="flex justify-between items-start">
            <div className="flex-1">
              <h3 className="font-medium text-gray-900">
                {user.name || 'No Name'}
              </h3>
              <p className="text-sm text-gray-600">{user.email}</p>
              <p className="text-xs text-gray-500 mt-1">
                Created: {new Date(user.createdAt).toLocaleString()}
              </p>
              <p className="text-xs text-gray-500">
                Posts: {user.posts.length}
              </p>
            </div>
            <button
              onClick={() => handleDelete(user.id)}
              disabled={deletingId === user.id}
              className="text-red-600 hover:text-red-800 text-sm font-medium disabled:opacity-50"
            >
              {deletingId === user.id ? 'Deleting...' : 'Delete'}
            </button>
          </div>
        </div>
      ))}
    </div>
  )
}