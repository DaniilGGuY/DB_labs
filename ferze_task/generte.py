arr = ['a', 'b', 'c', 'd', 'e', 'f', 'g', 'h']
for i in range(len(arr)):
    for j in range(len(arr)):
        if i != j:
            print(f'abs({arr[i]} - {arr[j]}) != {abs(j - i)} AND {arr[i]} != {arr[j]} AND ', end='')