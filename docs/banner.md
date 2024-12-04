
# SSHD Banner Text 
## Generation Script

Source: 
To run: `bash box_gen.sh "Text Here" or "Filename"`

!!! example "Boxed Text Generation"
  
    === "box_gen.sh"

        ``` bash
        
        cat > ~/box_gen.sh <<EOW
        #!/bin/bash

        # Check if an argument is provided
        if [ -z "$1" ]; then
            echo "Usage: $0 \"Your text here\" or $0 file2"
            exit 1
        fi

        # Check if the input is a file or text
        if [ -f "$1" ]; then
            # Read the contents of the file
            text=$(<"$1")
        else
            # Treat the argument as text
            text="$1"
        fi

        OUT_FILE="banner.txt"

        # Define fixed box width for content
        content_width=40
        box_width=$((content_width + 4)) # Add space for padding and borders

        # Generate the top and bottom borders
        border=$(printf '#%.0s' $(seq 1 $box_width))

        # Function to wrap text within the content width
        wrap_text() {
            echo "$1" | fold -sw $content_width
        }

        # Write the content to the file
        {
            echo "$border"
            printf "#%-*s#\n" $((box_width - 2)) ""
            printf "#%-*s#\n" $((box_width - 2)) "         Update"
            printf "#%-*s#\n" $((box_width - 2)) "         ----------"
            printf "#%-*s#\n" $((box_width - 2)) ""

            # Add the wrapped text line by line
            while IFS= read -r line; do
                printf "# %-*s #\n" $content_width "$line"
            done < <(wrap_text "$text")

            printf "#%-*s#\n" $((box_width - 2)) ""
            echo "$border"
        } > $OUT_FILE

        echo "Text written to $OUT_FILE successfully."
        EOW
        ```

    === "file1.txt"

        ``` bash
        cat > ~/file1.txt <<EOW
        Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry's standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen book. It has survived not only five centuries, but also the leap into electronic typesetting, remaining essentially unchanged. It was popularised in the 1960s with the release of Letraset sheets containing Lorem Ipsum passages, and more recently with desktop publishing software like Aldus PageMaker including versions of Lorem Ipsum.
        EOW

        ```

    === "banner.txt"

        ``` bash
        ############################################
        #                                          #
        #         Update                           #
        #         ----------                       #
        #                                          #
        # Lorem Ipsum is simply dummy text of the  #
        # printing and typesetting industry.       #
        # Lorem Ipsum has been the industry's      #
        # standard dummy text ever since the       #
        # 1500s, when an unknown printer took a    #
        # galley of type and scrambled it to make  #
        # a type specimen book. It has survived    #
        # not only five centuries, but also the    #
        # leap into electronic typesetting,        #
        # remaining essentially unchanged. It was  #
        # popularised in the 1960s with the        #
        # release of Letraset sheets containing    #
        # Lorem Ipsum passages, and more recently  #
        # with desktop publishing software like    #
        # Aldus PageMaker including versions of    #
        # Lorem Ipsum.                             #
        #                                          #
        ############################################


        ```



