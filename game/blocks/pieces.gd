extends Node

const ROTATIONS := 4

const o_0: Array[Vector2i] = [Vector2i(1, 0), Vector2i(2, 0), Vector2i(1, 1), Vector2i(2, 1)]
const o_90 := o_0
const o_180 := o_0
const o_270 := o_0
const o := [o_0, o_90, o_180, o_270]

const t_0: Array[Vector2i] = [Vector2i(1, 0), Vector2i(0, 1), Vector2i(1, 1), Vector2i(2, 1)]
const t_90: Array[Vector2i] = [Vector2i(1, 0), Vector2i(1, 1), Vector2i(2, 1), Vector2i(1, 2)]
const t_180: Array[Vector2i] = [Vector2i(0, 1), Vector2i(1, 1), Vector2i(2, 1), Vector2i(1, 2)]
const t_270: Array[Vector2i] = [Vector2i(1, 0), Vector2i(0, 1), Vector2i(1, 1), Vector2i(1, 2)]
const t := [t_0, t_90, t_180, t_270]

const i_0: Array[Vector2i] = [Vector2i(0, 1), Vector2i(1, 1), Vector2i(2, 1), Vector2i(3, 1)]
const i_90: Array[Vector2i] = [Vector2i(2, 0), Vector2i(2, 1), Vector2i(2, 2), Vector2i(2, 3)]
const i_180: Array[Vector2i] = [Vector2i(0, 2), Vector2i(1, 2), Vector2i(2, 2), Vector2i(3, 2)]
const i_270: Array[Vector2i] = [Vector2i(1, 0), Vector2i(1, 1), Vector2i(1, 2), Vector2i(1, 3)]
const i := [i_0, i_90, i_180, i_270]

const j_0: Array[Vector2i] = [Vector2i(0, 0), Vector2i(0, 1), Vector2i(1, 1), Vector2i(2, 1)]
const j_90: Array[Vector2i] = [Vector2i(1, 0), Vector2i(2, 0), Vector2i(1, 1), Vector2i(1, 2)]
const j_180: Array[Vector2i] = [Vector2i(0, 1), Vector2i(1, 1), Vector2i(2, 1), Vector2i(2, 2)]
const j_270: Array[Vector2i] = [Vector2i(1, 0), Vector2i(1, 1), Vector2i(0, 2), Vector2i(1, 2)]
const j := [j_0, j_90, j_180, j_270]

const l_0: Array[Vector2i] = [Vector2i(2, 0), Vector2i(0, 1), Vector2i(1, 1), Vector2i(2, 1)]
const l_90: Array[Vector2i] = [Vector2i(1, 0), Vector2i(1, 1), Vector2i(1, 2), Vector2i(2, 2)]
const l_180: Array[Vector2i] = [Vector2i(0, 1), Vector2i(1, 1), Vector2i(2, 1), Vector2i(0, 2)]
const l_270: Array[Vector2i] = [Vector2i(0, 0), Vector2i(1, 0), Vector2i(1, 1), Vector2i(1, 2)]
const l := [l_0, l_90, l_180, l_270]

const s_0: Array[Vector2i] = [Vector2i(1, 0), Vector2i(2, 0), Vector2i(0, 1), Vector2i(1, 1)]
const s_90: Array[Vector2i] = [Vector2i(1, 0), Vector2i(1, 1), Vector2i(2, 1), Vector2i(2, 2)]
const s_180: Array[Vector2i] = [Vector2i(1, 1), Vector2i(2, 1), Vector2i(0, 2), Vector2i(1, 2)]
const s_270: Array[Vector2i] = [Vector2i(0, 0), Vector2i(0, 1), Vector2i(1, 1), Vector2i(1, 2)]
const s := [s_0, s_90, s_180, s_270]

const z_0: Array[Vector2i] = [Vector2i(0, 0), Vector2i(1, 0), Vector2i(1, 1), Vector2i(2, 1)]
const z_90: Array[Vector2i] = [Vector2i(2, 0), Vector2i(1, 1), Vector2i(2, 1), Vector2i(1, 2)]
const z_180: Array[Vector2i] = [Vector2i(0, 1), Vector2i(1, 1), Vector2i(1, 2), Vector2i(2, 2)]
const z_270: Array[Vector2i] = [Vector2i(1, 0), Vector2i(0, 1), Vector2i(1, 1), Vector2i(0, 2)]
const z := [z_0, z_90, z_180, z_270]

const ALL := [o, t, i, j, l, s, z]
