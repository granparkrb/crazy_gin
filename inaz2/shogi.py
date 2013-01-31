#!/usr/bin/env python

import sys

def memoize(f):
    memo = {}
    def __f(*args, **kwargs):
        key = repr((args, kwargs))
        if not key in memo:
            memo[key] = f(*args, **kwargs)
        return memo[key]
    return __f

class Shogi():
    # 0 = empty, 1 = friend, 2 = king
    board = [
        0, 0, 0, 0, 2, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 1, 0,
        0, 0, 1, 0, 0, 1, 0, 0, 0,
        0, 0, 1, 1, 0, 0, 0, 1, 0,
        1, 1, 0, 0, 0, 0, 1, 0, 1,
        0, 0, 0, 1, 0, 1, 0, 0, 0,
        1, 1, 1, 0, 1, 0, 1, 1, 1,
    ]
    moves = [
        (-1, -1),
        (-1, 0),
        (-1, 1),
        (1, -1),
        (1, 1),
    ]
    max_depth = 20

    @memoize
    def step(self, xy, flags, depth):
        if depth >= Shogi.max_depth:
            is_accepted = flags['got_king'] and not flags['is_fallen'] and not flags['killed_friend']
            return int(is_accepted)

        num_accepted = 0
        for move in Shogi.moves:
            flags2 = dict(flags)
            xy2 = (xy[0] + move[0], xy[1] + move[1])
            is_now_fallen = not (0 <= xy2[0] <= 8 and 0 <= xy2[1] <= 8)
            flags2['is_fallen'] = flags2['is_fallen'] or is_now_fallen
            if not is_now_fallen:
                flags2['got_king'] = flags2['got_king'] or (Shogi.board[xy2[0]*9+xy2[1]] == 2)
                flags2['killed_friend'] = flags2['killed_friend'] or (Shogi.board[xy2[0]*9+xy2[1]] == 1)
            num_accepted_sub = self.step(xy2, flags2, depth+1)
            num_accepted = num_accepted + num_accepted_sub

        print >>sys.stderr, '[DEBUG] depth = %d, \txy = %s, \tnum_accepted = %d' % (depth, xy, num_accepted)
        return num_accepted

    def run(self):
        initial_flags = {'got_king': False, 'is_fallen': False, 'killed_friend': False}
        num_accepted = self.step((4, 4), initial_flags, 0)
        num_all_candidates = 5 ** Shogi.max_depth
        result = num_accepted/float(num_all_candidates)
        print '%d / %d = %f' % (num_accepted, num_all_candidates, result)

if __name__ == '__main__':
    Shogi().run()
