namespace :doctorlist do
  desc "Update doctors' names and license numbers"
  task create: :environment do
    doctors = [
      { doctor_name: "Medyan Alia", activity_clinician: "DHA-P-00021514" },
      { doctor_name: "Anas Karkout", activity_clinician: "DHA-P-00040970" },
      { doctor_name: "Alaa Nasser", activity_clinician: "DHA-P-00167721" },
      { doctor_name: "Rania Aljghami", activity_clinician: "DHA-P-00183296" },
      { doctor_name: "Salma Alsebaei", activity_clinician: "DHA-P-00204777" },
      { doctor_name: "Ali Alkourwe", activity_clinician: "DHA-P-00211344" },
      { doctor_name: "Saleh Alabdullah", activity_clinician: "DHA-P-00213654" },
      { doctor_name: "Maen Aburas", activity_clinician: "DHA-P-00248615" },
      { doctor_name: "Ekaterina Vokhmintseva", activity_clinician: "DHA-P-02406012" },
      { doctor_name: "Mohammed Alrousan", activity_clinician: "DHA-P-11132950" },
      { doctor_name: "Faissal Karisha", activity_clinician: "DHA-P-15196366" },
      { doctor_name: "Ahmad AlElewy", activity_clinician: "DHA-P-23098518" },
      { doctor_name: "Chinchu Matthew", activity_clinician: "DHA-P-23755972" },
      { doctor_name: "Antoine Habib", activity_clinician: "DHA-P-33304360" },
      { doctor_name: "Mai Saeed", activity_clinician: "DHA-P-34565364" },
      { doctor_name: "Adel Chidiac", activity_clinician: "DHA-P-44491817" },
      { doctor_name: "Ahmad Shalati", activity_clinician: "DHA-P-45383604" },
      { doctor_name: "Mohammad Khalil", activity_clinician: "DHA-P-57993809" },
      { doctor_name: "Julio Mendez", activity_clinician: "DHA-P-59570785" },
      { doctor_name: "Roza Yousuf", activity_clinician: "DHA-P-60141271" },
      { doctor_name: "Mahmoud Alahmad", activity_clinician: "DHA-P-60972285" },
      { doctor_name: "Rami Kalmat", activity_clinician: "DHA-P-81410067" },
      { doctor_name: "Sarmad Aburas", activity_clinician: "DHA-P-93589250" },
      { doctor_name: "Mouhamad Sami Al Rubeh", activity_clinician: "DHA-P-94001387" },
      { doctor_name: "Baraa Wardah", activity_clinician: "DHA-P-96192034" },
      { doctor_name: "Atefeh Tavakoli", activity_clinician: "DHA-P-97580088" },
      { doctor_name: "Anas Karkout", activity_clinician: "DHA-P-0040970" },
      { doctor_name: "Maen Aburas", activity_clinician: "DHA-P-0248615" },
      { doctor_name: "Alaa Nasser", activity_clinician: "DHA-P-0167721" },
      { doctor_name: "Medyan Alia", activity_clinician: "DHA-P-0021514" },
      { doctor_name: "Rania Aljghami", activity_clinician: "DHA-P-0183296" },
      { doctor_name: "Saleh Alabdullah", activity_clinician: "DHA-P-0213654" },
      { doctor_name: "Salma Alsebaei", activity_clinician: "DHA-P-0204777" },
      { doctor_name: "Ekaterina Vokhmintseva", activity_clinician: "DHA-P-2406012" },
      { doctor_name: "Lana Allahham", activity_clinician: "DHA-P-52784111" }
    ]

    doctors.each do |doc|
      # Split the name into first and last name
      name_parts = doc[:doctor_name].split(' ')
      first_name = name_parts.first
      last_name = name_parts[1..-1].join(' ')

      # Create or find the doctor record
      doctor = Doctorlist.find_or_initialize_by(activity_clinician: doc[:activity_clinician])
      
      # Build associated user if needed
      if doctor.userable.nil?
        base_email = "#{first_name.downcase}.#{last_name.downcase.gsub(/\s/, '')}"
        email = "#{base_email}@example.com"
        
        # Handle duplicate emails by appending numbers
        counter = 1
        while User.exists?(email: email)
          email = "#{base_email}#{counter += 1}@example.com"
        end

        user = User.new(
          first_name: first_name,
          last_name: last_name,
          email: email,
          password: 'password123',
          password_confirmation: 'password123'
        )
        doctor.userable = user
      else
        # Update existing user's names
        user = doctor.userable
        user.first_name = first_name
        user.last_name = last_name
        
        # Also check and update email if needed
        base_email = "#{first_name.downcase}.#{last_name.downcase.gsub(/\s/, '')}"
        new_email = "#{base_email}@example.com"
        
        if user.email != new_email && User.exists?(email: new_email)
          counter = 1
          while User.exists?(email: "#{base_email}#{counter}@example.com")
            counter += 1
          end
          user.email = "#{base_email}#{counter}@example.com"
        elsif user.email != new_email
          user.email = new_email
        end
      end

      # Save both records
      if doctor.save && (doctor.userable.new_record? ? doctor.userable.save : true)
        puts "Record updated: #{doctor.inspect}"
      else
        puts "Failed to save: #{doctor.errors.full_messages.join(', ')}"
        if doctor.userable
          puts "User errors: #{doctor.userable.errors.full_messages.join(', ')}"
        end
      end
    end
  end
end