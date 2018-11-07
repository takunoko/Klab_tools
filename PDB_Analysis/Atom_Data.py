# 原子単体を扱うためのクラス

class Atom:
    x=0
    y=0
    z=0
    def __init__(self, x, y, z):
        self.x = x
        self.y = y
        self.z = z

if __name__ == "__main__":
    A = Atom(10, 20, 23)
    print('{0},{1},{2}'.format(A.x, A.y, A.z))
