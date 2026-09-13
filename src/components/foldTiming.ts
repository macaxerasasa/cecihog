/* Shared by the map (which drives the phases) and the fold-out (which plays
   them), kept apart so the reader stays its own chunk. */
export type FoldPhase = 'lifting' | 'unfolding' | 'open' | 'folding' | 'returning'

export const LIFT_MS = 420
export const UNFOLD_MS = 640
export const FOLD_MS = 480
export const RETURN_MS = 380
