/* 
 * stoplight.c
 *
 * 31-1-2003 : GWA : Stub functions created for CS161 Asst1.
 *
 * NB: You can use any synchronization primitives available to solve
 * the stoplight problem in this file.
 */


/*
 * 
 * Includes
 *
 */

#include <types.h>
#include <lib.h>
#include <test.h>
#include <thread.h>
#include <synch.h>

static struct sempahore *region0; //north west
static struct sempahore *region1; //north east
static struct sempahore *region2; //south west
static struct sempahore *region3; //south east
static struct semaphore *intersection_car_count; //total number of cars in the intersection to prevent deadlock


/*
 *
 * Constants
 *
 */

/*
 * Number of cars created.
 */

#define NCARS 20


/*
 *
 * Function Definitions
 *
 */

static const char *directions[] = { "N", "E", "S", "W" };

static const char *msgs[] = {
        "approaching:",
        "region1:    ",
        "region2:    ",
        "region3:    ",
        "leaving:    "
};

/* use these constants for the first parameter of message */
enum { APPROACHING, REGION1, REGION2, REGION3, LEAVING };

static void
message(int msg_nr, int carnumber, int cardirection, int destdirection)
{
        kprintf("%s car = %2d, direction = %s, destination = %s\n",
                msgs[msg_nr], carnumber,
                directions[cardirection], directions[destdirection]);
}
 
/*
 * gostraight()
 *
 * Arguments:
 *      unsigned long cardirection: the direction from which the car
 *              approaches the intersection.
 *      unsigned long carnumber: the car id number for printing purposes.
 *
 * Returns:
 *      nothing.
 *
 * Notes:
 *      This function should implement passing straight through the
 *      intersection from any direction.
 *      Write and comment this function.
 */

static
void
gostraight(unsigned long cardirection,
           unsigned long carnumber)
{
        /*
         * Avoid unused variable warnings.
         */
        
        (void) cardirection;
        (void) carnumber;
		if (cardirection == 0){ //from north
			P(intersection_car_count); //make sure only 3 or fewer cars at the intersection to prevent deadlock
			message(0, carnumber, cardirection, 2); //approaching intersection
			
			P(region0); //semaphore acquire for first region
			
			message(1,carnumber, cardirection, 2); //entering first region
			P(region2); //semaphore acquire for first region
			message(2,carnumber, cardirection, 2); //entering second region
			V(region0); //give up the semaphore for the first region 
			message(4, carnumber,cardirection, 2); //leaving the intersection
			V(region2); //give up the semaphore for the second region 
			V(intersection_car_count); //release the semaphore for car count at the intersection

		}	
		else if (cardirection == 1){ //from east
			P(intersection_car_count); //make sure only 3 or fewer cars at the intersection to prevent deadlock
			message(0, carnumber, cardirection, 3); //approaching intersection
			
			P(region1); //semaphore acquire for first region
			
			
			message(1,carnumber, cardirection, 3); //enter first region
			P(region0); //semaphore acquire for first region
			message(2,carnumber, cardirection, 3); //enter second region
			V(region1); //release the semaphore for the first region
			message(4, carnumber,cardirection, 3); //leaving the intersection
			V(region0); //give up the semaphore for the second region
			V(intersection_car_count); //release the semaphore for car count
		}	
		else if (cardirection == 2){ //from south
			P(intersection_car_count); //make sure only 3 or fewer cars at the intersection to prevent deadlock
			message(0, carnumber, cardirection, 0); //approaching intersection
			
			P(region3);//semaphore acquire for first region
			
			
			message(1,carnumber, cardirection, 0);//enter first region
			P(region1);//semaphore acquire for first region
			message(2,carnumber, cardirection, 0);//enter second region
			V(region3);//release the semaphore for the first region
			message(4, carnumber,cardirection, 0);	//leaving the intersection	
			V(region1);//give up the semaphore for the second region
			V(intersection_car_count); //release the semaphore for car count

		}	
		else if (cardirection == 3){ //from west
			P(intersection_car_count);
			message(0, carnumber, cardirection, 1); //same as statements above but for different cases
			
			P(region2);
			
			
			message(1,carnumber, cardirection, 1);
			P(region3);
			message(2,carnumber, cardirection, 1);
			V(region2);
			message(4, carnumber,cardirection, 1);		
			V(region3);
			V(intersection_car_count);

		}	

}


/*
 * turnleft()
 *
 * Arguments:
 *      unsigned long cardirection: the direction from which the car
 *              approaches the intersection.
 *      unsigned long carnumber: the car id number for printing purposes.
 *
 * Returns:
 *      nothing.
 *
 * Notes:
 *      This function should implement making a left turn through the 
 *      intersection from any direction.
 *      Write and comment this function.
 */

static
void
turnleft(unsigned long cardirection,
         unsigned long carnumber)
{
        /*
         * Avoid unused variable warnings.
         */

        (void) cardirection;
        (void) carnumber;
		if (cardirection == 0){ //from north
			P(intersection_car_count);
			message(0, carnumber, cardirection, 1);
			P(region0);
			message(1,carnumber, cardirection, 1);
			P(region2);
			message(2,carnumber, cardirection, 1);
			V(region0);
			P(region3);
			message(3,carnumber, cardirection, 1);
			V(region2);
			message(4, carnumber,cardirection, 1);		
			V(region3);
			V(intersection_car_count);

		}	
		else if (cardirection == 1){ //from east
			P(intersection_car_count);
			message(0, carnumber, cardirection, 2);
			
			P(region1);
			message(1,carnumber, cardirection, 2);
			P(region0);
			message(2,carnumber, cardirection, 2);
			V(region1);
			P(region2);
			
			
			
			message(3,carnumber, cardirection, 2);
			V(region0);
			message(4, carnumber,cardirection, 2);		
			V(region2);
			V(intersection_car_count);

		}	
		else if (cardirection == 2){ //from south
			P(intersection_car_count);
			message(0, carnumber, cardirection, 3);
			
			P(region3);
			message(1,carnumber, cardirection, 3);
			P(region1);
			message(2,carnumber, cardirection, 3);
			V(region3);
			P(region0);
			
			
			
			message(3,carnumber, cardirection, 3);
			V(region1);
			message(4, carnumber,cardirection, 3);		
			V(region0);
			V(intersection_car_count);

		}	
		else if (cardirection == 3){ //from west
			P(intersection_car_count);
			message(0, carnumber, cardirection, 0);
			
			P(region2);
			message(1,carnumber, cardirection, 0);
			P(region3);
			message(2,carnumber, cardirection, 0);
			V(region2);
			P(region1);
			
			
			
			message(3,carnumber, cardirection, 0);
			V(region3);
			message(4, carnumber,cardirection, 0);		
			V(region1);
			V(intersection_car_count);

		}	

}


/*
 * turnright()
 *
 * Arguments:
 *      unsigned long cardirection: the direction from which the car
 *              approaches the intersection.
 *      unsigned long carnumber: the car id number for printing purposes.
 *
 * Returns:
 *      nothing.
 *
 * Notes:
 *      This function should implement making a right turn through the 
 *      intersection from any direction.
 *      Write and comment this function.
 */

static
void
turnright(unsigned long cardirection,
          unsigned long carnumber)
{
        /*
         * Avoid unused variable warnings.
         */

        (void) cardirection;
        (void) carnumber;
		if (cardirection == 0){ //from north
			P(intersection_car_count);
			message(0, carnumber, cardirection, 3);
			
			P(region0);
			message(1,carnumber, cardirection, 3);
			message(4, carnumber,cardirection, 3);		
			V(region0);
			V(intersection_car_count);

		}	
		else if (cardirection == 1){ //from east
			P(intersection_car_count);
			message(0, carnumber, cardirection, 0);
			
			P(region1);
			message(1,carnumber, cardirection, 0);
			message(4, carnumber,cardirection, 0);		
			V(region1);
			V(intersection_car_count);

		}	
		else if (cardirection == 2){//from south
			P(intersection_car_count);
			message(0, carnumber, cardirection, 1);
			
			P(region3);
			
			message(1,carnumber, cardirection, 1);
			message(4, carnumber,cardirection, 1);		
			V(region3);
			V(intersection_car_count);
		}	
		else if (cardirection == 3){//from west
			P(intersection_car_count);
			message(0, carnumber, cardirection, 2);
			
			P(region2);
			
			message(1,carnumber, cardirection, 2);
			message(4, carnumber,cardirection, 2);		
			V(region2);
			V(intersection_car_count);

		}	

}


/*
 * approachintersection()
 *
 * Arguments: 
 *      void * unusedpointer: currently unused.
 *      unsigned long carnumber: holds car id number.
 *
 * Returns:
 *      nothing.
 *
 * Notes:
 *      Change this function as necessary to implement your solution. These
 *      threads are created by createcars().  Each one must choose a direction
 *      randomly, approach the intersection, choose a turn randomly, and then
 *      complete that turn.  The code to choose a direction randomly is
 *      provided, the rest is left to you to implement.  Making a turn
 *      or going straight should be done by calling one of the functions
 *      above.
 */
 
static
void
approachintersection(void * unusedpointer,
                     unsigned long carnumber)
{
        int cardirection;
		int destdirection;

        /*
         * Avoid unused variable and function warnings.
         */

        (void) unusedpointer;
        (void) carnumber;
	(void) gostraight;
	(void) turnleft;
	(void) turnright;

        /*
         * cardirection is set randomly.
         */

        cardirection = random() % 4;//randomize the starting car direction
		destdirection = random() % 4;//randomize the destination

		while (destdirection == cardirection){//prevent u-turn
			destdirection = random() % 4;
		}
		
		//figure what action the car should take given the starting and destination direction
		if (cardirection == 0){
			if (destdirection == 1){
				turnleft(cardirection, carnumber);
			}
			else if (destdirection == 2){
				gostraight(cardirection, carnumber);
			}
			else if (destdirection == 3){
				turnright(cardirection, carnumber);
			}
		}
		else if (cardirection == 1){
			if (destdirection == 2){
				turnleft(cardirection, carnumber);
			}
			else if (destdirection == 3){
				gostraight(cardirection, carnumber);
			}
			else if (destdirection == 0){
				turnright(cardirection, carnumber);
			}
		}
		else if (cardirection == 2){
			if (destdirection == 3){
				turnleft(cardirection, carnumber);
			}
			else if (destdirection == 0){
				gostraight(cardirection, carnumber);
			}
			else if (destdirection == 1){
				turnright(cardirection, carnumber);
			}
		}
		else if (cardirection == 3){
			if (destdirection == 0){
				turnleft(cardirection, carnumber);
			}
			else if (destdirection == 1){
				gostraight(cardirection, carnumber);
			}
			else if (destdirection == 2){
				turnright(cardirection, carnumber);
			}
		}
		
}


/*
 * createcars()
 *
 * Arguments:
 *      int nargs: unused.
 *      char ** args: unused.
 *
 * Returns:
 *      0 on success.
 *
 * Notes:
 *      Driver code to start up the approachintersection() threads.  You are
 *      free to modiy this code as necessary for your solution.
 */

int
createcars(int nargs,
           char ** args)
{
        int index, error;

        /*
         * Avoid unused variable warnings.
         */

        (void) nargs;
        (void) args;

        /*
         * Start NCARS approachintersection() threads.
         */
		if (region0 == NULL){//create the semaphores in use
			region0 = sem_create("region0",1);
		}
		if (region1 == NULL){
			region1 = sem_create("region1",1);
		}
		if (region2 == NULL){
			region2 = sem_create("region2",1);
		}
		if (region3 == NULL){
			region3 = sem_create("region3",1);
		}
		if (intersection_car_count == NULL){
			intersection_car_count = sem_create("intersection_car_count",3);
		}
		
		
		
		

        for (index = 0; index < NCARS; index++) {

                error = thread_fork("approachintersection thread",
                                    NULL,
                                    index,
                                    approachintersection,
                                    NULL
                                    );

                /*
                 * panic() on error.
                 */

                if (error) {
                        
                        panic("approachintersection: thread_fork failed: %s\n",
                              strerror(error)
                              );
                }
        }

        return 0;
}
