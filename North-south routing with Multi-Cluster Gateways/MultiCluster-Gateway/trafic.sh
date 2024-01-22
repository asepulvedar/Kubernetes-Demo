i=0
while true 
do
	
	echo "$i"
	curl -H "host: store.example.com" http://34.107.233.131/east
	curl -H "host: store.example.com" http://34.107.233.131/west
	curl -H "host: store.example.com" http://34.107.233.131/
	let i++
	sleep 0.01
done
