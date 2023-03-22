
import csv 
# Open the input file 
with open("/tmp/mozilla_estudante0/sisvan_estado_nutricional_2021.csv", "r", encoding='latin-1') as input_file: 
    # Create a CSV reader object 
    reader = csv.reader(input_file) 
    # Initialize a counter variable 
    count = 0 
    # Iterate over the rows in the input file 
    for row in reader: 
        # If the counter is equal to 0, create a new output file 
            # Increment the counter 
            count += 1 
            # Create a new output file with the name "data_part_1.csv" 
            with open("data_part_1.csv", "w") as output_file: 
                # Create a CSV writer object 
                writer = csv.writer(output_file) 
                # Write the first row to the output file 
                writer.writerow(row) 
                # If the counter is not equal to 0, write the row to the existing output file 
                # Increment the counter 
                count += 1 
                # Write the row to the existing output file 
                writer.writerow(row) 
                print()
                # If the counter is equal to 1000, reset the counter 
                if count == 1000:          
                    exit()
