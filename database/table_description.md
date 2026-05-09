# PetroVision Tables Description

## users

Stores user account and authentication information.

Main fields:

* user_id
* email
* fname
* lname
* phone
* password

---

## admin

Stores administrator-specific information.

Main fields:

* user_id
* job_number

---

## customer

Stores customer-specific information.

Main fields:

* user_id
* username

---

## station

Stores fuel station information and location data.

Main fields:

* station_id
* station_name
* city
* address
* latitude
* longitude
* status

---

## historical_station_metrics

Stores historical operational and performance data used for AI analysis and prediction models.

Main fields:

* station_id
* date
* traffic_index
* transactions
* total_sales
* complaints_count
* queue_time_avg
* performance_score

---

## loyalty_account

Stores customer loyalty points.

Main fields:

* account_id
* user_id
* current_points

---

## loyalty_program

Stores loyalty program information.

Main fields:

* program_id
* type
* description

---

## membership

Stores customer membership and tier information.

Main fields:

* membership_id
* account_id
* user_id
* tier
* status

---

## offer

Stores rewards and loyalty offers.

Main fields:

* offer_id
* name
* category
* earn_points
* redeem_points
* status

---

## transactions

Stores loyalty and rewards transaction history.

Main fields:

* transaction_id
* account_id
* station_id
* amount
* points
* type

---

## report

Stores generated AI analysis reports and recommendations.

Main fields:

* report_id
* station_id
* model_name
* summary
* recommendation
* generation_time
