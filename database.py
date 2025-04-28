def change_list(mylist):
    mylist.append(4)
    print('inside function:', mylist)


a = [1, 2, 3]
change_list(a)    
print('outside function:', a)