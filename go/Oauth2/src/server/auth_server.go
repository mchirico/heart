package main

import (
	"crypto/hmac"
	"crypto/sha1"
	"encoding/json"
	"flag"
	"fmt"
	"io/ioutil"
	"log"
	"net/http"
	"time"
)

var (
	// flagPort is the open port the application listens on
	flagPort = flag.String("port", "2323", "Port to listen on")
)

var results []string

func keyCheck(r *http.Request) ([]byte, bool) {

	log.Printf("Now Body Read\n")
	body, err := ioutil.ReadAll(r.Body)
	if err != nil {
		panic(err)
	}
	log.Println(string(body))

	secret := "SpecialGit3928alksKEY"
	key := []byte(secret)
	h := hmac.New(sha1.New, key)
	h.Write([]byte(body))
	fmt.Printf("\n\nsha1=%x\n\n", h.Sum(nil))

	calKey := fmt.Sprintf("sha1=%x", h.Sum(nil))
	if calKey != r.Header.Get("X-Hub-Signature") {
		log.Printf("We have a problem. calKey and X-Hub-Signature do not match:%v,%v\n\n", calKey, r.Header.Get("X-Hub-Signature"))
		return body, false
	} else {
		log.Printf("Good,Keys match:%v,%v\n", calKey, r.Header.Get("X-Hub-Signature"))
		return body, true
	}
	return body, false
}

// GetHandler handles the index route
func GetHandler(w http.ResponseWriter, r *http.Request) {
	jsonBody, err := json.Marshal(results)
	if err != nil {
		http.Error(w, "Error converting results to json",
			http.StatusInternalServerError)
	}
	fmt.Println("GET")
	w.Write(jsonBody)
}

// PostHandler converts post request body to string
func PostHandler(w http.ResponseWriter, r *http.Request) {

	body, valid := keyCheck(r)

	if valid == true {
		jsonBody, err := json.Marshal(string(body))
		if err != nil {

		} else {
			fmt.Printf("jsonBody:\n%s\n", jsonBody)
		}
	}

	for k, v := range r.Header {
		fmt.Printf("Header field %q, Value %q\n", k, v)
	}

	fmt.Printf("Host = %q\n", r.Host)
	fmt.Printf("RemoteAddr= %q\n", r.RemoteAddr)

	body, err := ioutil.ReadAll(r.Body)
	if err != nil {
		panic(err)
	}
	fmt.Printf("body:\n%s\n\n", string(body))
	defer r.Body.Close()

	if r.Method == "GET" {
		GetHandler(w, r)
		return
	}

	fmt.Println("In post")

	if r.Method == "POST" {
		body, err := ioutil.ReadAll(r.Body)
		if err != nil {
			http.Error(w, "Error reading request body",
				http.StatusInternalServerError)
		}
		results = append(results, string(body))

		fmt.Fprint(w, "POST done")
	} else {
		http.Error(w, "Invalid request method", http.StatusMethodNotAllowed)
	}
}

func init() {
	log.SetFlags(log.Lmicroseconds | log.Lshortfile)
	flag.Parse()
}

func main() {
	results = append(results, time.Now().Format(time.RFC3339))

	mux := http.NewServeMux()
	//mux.HandleFunc("/", GetHandler)
	mux.HandleFunc("/", PostHandler)

	log.Printf("listening on port %s", *flagPort)
	log.Fatal(http.ListenAndServe(":"+*flagPort, mux))
}

/*


Example code:
curl -H "Content-Type: application/json" -X GET -d '{"username":"xyz","password":"xyz"}' http://localhost:2323/http_stuff

Ref:
https://gist.github.com/rjz/b51dc03061dbcff1c521

*/
