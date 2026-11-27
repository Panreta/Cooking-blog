import { createClient } from '@supabase/supabase-js';
import { SUPABASE_URL, SUPABASE_ANON_KEY } from '../config';

export const supabase = createClient(SUPABASE_URL, SUPABASE_ANON_KEY);

export const isConfigured = !SUPABASE_URL.includes('YOUR-PROJECT');

export interface Step {
  text: string;
  photo: string | null;
}

export interface Post {
  id: string;
  author_id: string;
  author_name: string;
  title: string;
  description: string;
  cover_url: string;
  prep_time: string | null;
  cook_time: string | null;
  servings: string | null;
  tags: string[];
  ingredients: string[];
  story: string;
  steps: Step[];
  tips: string;
  created_at: string;
}

export async function getUser() {
  const { data } = await supabase.auth.getSession();
  return data.session?.user ?? null;
}

export function displayName(user: { email?: string; user_metadata?: Record<string, unknown> }) {
  return (user.user_metadata?.display_name as string) || user.email?.split('@')[0] || 'Anonymous';
}

// Shrink photos in the browser before upload so phone pictures don't eat the storage quota.
async function resize(file: File, maxSize = 1800): Promise<Blob> {
  const bitmap = await createImageBitmap(file).catch(() => null);
  if (!bitmap) return file;
  const scale = Math.min(1, maxSize / Math.max(bitmap.width, bitmap.height));
  const canvas = document.createElement('canvas');
  canvas.width = Math.round(bitmap.width * scale);
  canvas.height = Math.round(bitmap.height * scale);
  canvas.getContext('2d')!.drawImage(bitmap, 0, 0, canvas.width, canvas.height);
  return new Promise((resolve) => canvas.toBlob((b) => resolve(b ?? file), 'image/jpeg', 0.85));
}

export async function uploadPhoto(file: File, userId: string) {
  const blob = await resize(file);
  const path = `${userId}/${crypto.randomUUID()}.jpg`;
  const { error } = await supabase.storage.from('photos').upload(path, blob, { contentType: 'image/jpeg' });
  if (error) throw error;
  return supabase.storage.from('photos').getPublicUrl(path).data.publicUrl;
}
