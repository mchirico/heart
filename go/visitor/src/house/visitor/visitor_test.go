package visitor

import (
	"reflect"
	"testing"
	"fmt"

)

func TestVisitor(t *testing.T) {

	expected := []string{"Visiting the front left wheel\n", 
		"Visiting the front right wheel\n",
		"Visiting the rear right wheel\n",
		"Visiting the rear left wheel\n",
		"Visiting engine\n",
	}
	


	car := NewCar()
	visitor := new(GetMessageVisitor)
	car.Accept(visitor)

	if reflect.DeepEqual(expected, visitor.Messages) {
		fmt.Printf("Match")
	} else {
		t.Errorf("Output does not match")
	}

	
	}






