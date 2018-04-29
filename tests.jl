q=[1 0 0 0 1;
0 0 1 1 1;
0 1 0 1 0]
T=[Time_serv(1,100) Time_serv(2,100.2) Time_serv(3,150)]
attributs=[1 3 5]

(m,n)=size(q)


attrib = 1:n
servers = 1:m
x=10
for i in servers
    println(i)
end
