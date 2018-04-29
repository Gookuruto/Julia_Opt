using JuMP
using GLPKMathProgInterface

immutable Time_serv
    serv::Int   #server number
    time::Float64  #search time for server
end


####DATA
q=[1 0 0 0 1 0 1;
0 0 1 1 1 0 0;
0 1 0 1 0 1 1]
T=[100 10 50]
attributs=[1 3 5 7]

(m,n)=size(q)


##model
model = Model(solver=GLPKSolverMIP())



attrib = 1:n
servers = 1:m

@variable(model,x[servers]>=0)


@objective(model,Min,sum(T[t]*x[t] for t in servers))


for a in attributs
    #if q[i,a]==1
    @constraint(model, sum(x[k] for k in servers if q[k,a]==1)>=1)
    #end
end

print(model) # print the instance of problem

status = solve(model, suppress_warnings=true) # solve model



if status==:Optimal
     println("the total cost: ", getobjectivevalue(model))
    println("x: ", getvalue(x)) # a shortest path
else
   println("Status: ", status)
end
