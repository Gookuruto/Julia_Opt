using JuMP
using GLPKMathProgInterface

function jobshop(d::Matrix{Int})
  (m,n)=size(d)

#  m - liczba zadan
#  n - liczba maszyn
#  d - macierz mxn zawierajaca czasy wykonania i-tego zadania na j-tej maszynie


 B=sum(d) #duza liczba wraz z inicjalizacja

 model = Model(solver = GLPKSolverMIP()) # wybor solvera
 #model = Model(solver = CplexSolver())

 Task = 1:m
 Machine = 1:n
 Precedence =[(j,i,k) for j in Machine, i in Task, k in Task if i<k]

	#  zmienne moment rozpoczecia i-tego zadania na j-tej maszynie
	@variable(model, t[Task,Machine]>=0)
	# zmienna czas zakonczenia wykonawania wszystkich zadan - makespan
	@variable(model, ms>=0)

	# zmienne pomocnicze
	# potrzebne przy zamienia ograniczen zasobowych
	@variable(model, y[Precedence],Bin)

	# minimalizacja czasu zakonczenia wszystkich zadan
	@objective(model,Min, ms)




  # moment rozpoczecia i-tego zadania na j+1-szej maszynie
  # musi >= od momentu zakonczenia i-tego zadania na j-tej maszynie
	for i in Task, j in Machine
	  if j<n
			@constraint(model, t[i,j+1]>=t[i,j]+d[i,j])
			 # t_ij>=t_kj+d_kj lub t_kj>=t_ij+d_ij
		end
	end







  # ograniczenia zosobowe tj,. tylko jedno zadanie wykonywane jest
  # w danym momencie na j-tej maszynie
	for (j,i,k) in Precedence
	  @constraint(model, t[i,j]-t[k,j]+B*y[(j,i,k)]>=d[k,j])
	  @constraint(model, t[k,j]-t[i,j]+B*(1-y[(j,i,k)])>=d[i,j])
  end
	# ms rowna sie czas zakonczenia wszystkich zadan na ostatniej maszynie
	for i in Task
		 @constraint(model,t[i,n]+d[i,n]<=ms)
	end

	print(model) # drukuj model

	status = solve(model) # rozwiaz egzemplarz

	if status==:Optimal
		 return status, getobjectivevalue(model), getvalue(t)
	else
		return status, nothing,nothing
	end

end #jobshop




# czasy wykonia i-tego zadania na j-tej maszynie
d =  [3       3       2;
      9       3       8;
      9       8       5;
      4       8       4;
      6      10       3;
      6       3       1;
      7      10       3]



(status, makespan, czasy)=jobshop(d)

if status==:Optimal
	 println("makespan: ", makespan)
   println("czasy rozpoczecia zadan: ", czasy)
else
   println("Status: ", status)
end
