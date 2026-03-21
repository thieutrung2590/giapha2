import { createClient } from '@/utils/supabase/server'

/**
 * Lấy user hiện tại từ Supabase Auth
 */
export const getUser = async () => {
  const supabase = await createClient()

  const {
    data: { user },
    error,
  } = await supabase.auth.getUser()

  if (error) {
    console.error('getUser error:', error)
    return null
  }

  return user
}

/**
 * Lấy profile theo user id
 */
export const getProfile = async (userId?: string) => {
  const supabase = await createClient()

  // nếu không truyền userId → lấy từ auth
  let uid = userId

  if (!uid) {
    const user = await getUser()
    uid = user?.id
  }

  if (!uid) return null

  const { data, error } = await supabase
    .from('profiles')
    .select('*')
    .eq('id', uid)
    .single()

  if (error) {
    console.error('getProfile error:', error)
    return null
  }

  return data
}

/**
 * Kiểm tra user có phải admin không
 */
export const getIsAdmin = async () => {
  const profile = await getProfile()

  if (!profile) return false

  return profile.role === 'admin'
}

/**
 * Kiểm tra user đã được kích hoạt chưa
 */
export const getIsActive = async () => {
  const profile = await getProfile()

  if (!profile) return false

  return profile.is_active === true
}
